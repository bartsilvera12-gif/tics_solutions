// Recibe el formulario de contacto y lo manda por correo.
//
// Corre como función serverless de Vercel: el navegador nunca ve las
// credenciales, que viven en las variables de entorno del proyecto.
//
// Variables que hay que cargar en Vercel (Settings -> Environment Variables):
//   SMTP_HOST       smtp.gmail.com
//   SMTP_PORT       465
//   SMTP_SECURE     true
//   SMTP_USER       arturo.osorio@tics-py.com
//   SMTP_PASSWORD   contraseña de aplicación de Google (no la del correo)
//   CONTACT_EMAIL   arturo.osorio@tics-py.com
//
// Y para que la consulta quede registrada en el panel:
//   SUPABASE_URL                https://api.neura.com.py
//   SUPABASE_SERVICE_ROLE_KEY   solo acá, nunca en el navegador
//
// La escritura va con la service_role desde el servidor y no con la anon key
// desde el sitio: así la tabla de consultas no queda abierta a que cualquiera
// le inserte filas desde afuera.

const nodemailer = require('nodemailer');

const LIMITES = { nombre: 100, empresa: 150, correo: 200, telefono: 50, mensaje: 5000 };
const CORREO_VALIDO = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const SCHEMA = 'ticspy';

// ---------------------------------------------------------------------------
// Registro de la consulta
// ---------------------------------------------------------------------------
// Ninguna de estas dos funciones tira: si la base no responde, la consulta
// tiene que salir igual por correo. Perder un pedido de presupuesto porque se
// cayó Postgres sería el peor resultado posible.

async function guardarConsulta(datos, ruta) {
  const { SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = process.env;

  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return null;
  }

  try {
    const r = await fetch(SUPABASE_URL + '/rest/v1/contact_submissions', {
      method: 'POST',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: 'Bearer ' + SUPABASE_SERVICE_ROLE_KEY,
        'Content-Type': 'application/json',
        'Content-Profile': SCHEMA,
        Prefer: 'return=representation'
      },
      body: JSON.stringify({
        name: datos.nombre,
        company: datos.empresa || null,
        email: datos.correo,
        phone: datos.telefono || null,
        message: datos.mensaje,
        source_route: ruta || null,
        status: 'new'
      })
    });

    if (!r.ok) {
      const detalle = await r.text();
      console.error('No se pudo guardar la consulta:', r.status, detalle);
      return null;
    }
    const filas = await r.json();
    return filas && filas[0] ? filas[0].id : null;
  } catch (error) {
    console.error('No se pudo guardar la consulta:', error && error.message);
    return null;
  }
}

async function marcarConsulta(id, campos) {
  const { SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = process.env;
  if (!id || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) return;

  try {
    await fetch(SUPABASE_URL + '/rest/v1/contact_submissions?id=eq.' + encodeURIComponent(id), {
      method: 'PATCH',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: 'Bearer ' + SUPABASE_SERVICE_ROLE_KEY,
        'Content-Type': 'application/json',
        'Content-Profile': SCHEMA,
        Prefer: 'return=minimal'
      },
      body: JSON.stringify(campos)
    });
  } catch (error) {
    console.error('No se pudo actualizar la consulta:', error && error.message);
  }
}

function escaparHtml(v) {
  return String(v)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function texto(v) {
  return String(v == null ? '' : v).trim();
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Método no permitido.' });
  }

  let cuerpo;
  try {
    cuerpo = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
  } catch (e) {
    return res.status(400).json({ error: 'No pudimos leer los datos enviados.' });
  }
  if (!cuerpo || typeof cuerpo !== 'object') {
    return res.status(400).json({ error: 'No pudimos leer los datos enviados.' });
  }

  // Campo trampa: una persona no lo ve, un robot lo completa. Se responde
  // como si hubiera salido bien para que el robot no aprenda a esquivarlo.
  if (texto(cuerpo.website)) {
    return res.status(200).json({ success: true, message: 'Consulta enviada correctamente.' });
  }

  const datos = {
    nombre: texto(cuerpo.nombre),
    empresa: texto(cuerpo.empresa),
    correo: texto(cuerpo.correo),
    telefono: texto(cuerpo.telefono),
    mensaje: texto(cuerpo.mensaje)
  };

  if (!datos.nombre || !datos.correo || !datos.mensaje) {
    return res.status(400).json({ error: 'Completá los campos obligatorios.' });
  }
  if (!CORREO_VALIDO.test(datos.correo)) {
    return res.status(400).json({ error: 'Ingresá un correo válido.' });
  }
  for (const campo of Object.keys(LIMITES)) {
    if (datos[campo].length > LIMITES[campo]) {
      return res.status(400).json({ error: 'Uno o más campos exceden el límite permitido.' });
    }
  }

  // Se registra ANTES de mandar el correo. Si el envío falla, la consulta ya
  // quedó guardada y se ve en el panel; al revés se perdería.
  const idConsulta = await guardarConsulta(datos, texto(cuerpo.ruta) || null);

  const { SMTP_USER, SMTP_PASSWORD, CONTACT_EMAIL } = process.env;
  if (!SMTP_USER || !SMTP_PASSWORD || !CONTACT_EMAIL) {
    // Al servidor le sirve el detalle; al navegador, no.
    console.error('Faltan variables SMTP en el entorno del proyecto.');
    // Si alcanzó a guardarse, la consulta no se perdió: queda en el panel con
    // el correo marcado como no enviado, y a quien escribió no se le miente
    // diciendo que hubo un problema cuando su mensaje sí llegó.
    if (idConsulta) {
      return res.status(200).json({ success: true, message: 'Consulta enviada correctamente.' });
    }
    return res.status(500).json({ error: 'El servicio de correo no está configurado.' });
  }

  const transporte = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: Number(process.env.SMTP_PORT || 465),
    // El 465 abre en TLS desde el saludo. La variable existe por si alguna vez
    // hay que ir a 587, pero cualquier valor que no sea "false" deja el TLS puesto.
    secure: String(process.env.SMTP_SECURE || 'true') !== 'false',
    auth: { user: SMTP_USER, pass: SMTP_PASSWORD }
  });

  const sinDato = (v, alt) => (v ? v : alt);

  const plano = [
    'Nueva consulta recibida desde la página web de Tic\'s Solutions.',
    '',
    'Nombre: ' + datos.nombre,
    'Empresa: ' + sinDato(datos.empresa, 'No especificada'),
    'Correo: ' + datos.correo,
    'Teléfono: ' + sinDato(datos.telefono, 'No especificado'),
    '',
    'Mensaje:',
    datos.mensaje
  ].join('\n');

  const fila = (etiqueta, valor) =>
    '<p style="margin:0 0 10px;"><strong>' + etiqueta + ':</strong> ' + valor + '</p>';

  const html =
    '<div style="font-family:Arial,Helvetica,sans-serif;max-width:600px;margin:auto;color:#1D1E1E;">' +
      '<div style="border-bottom:3px solid #E71917;padding-bottom:15px;margin-bottom:25px;">' +
        '<h2 style="margin:0;font-size:20px;">Nueva consulta desde la web</h2>' +
        '<p style="margin:5px 0 0;color:#666;">Tic&rsquo;s Solutions</p>' +
      '</div>' +
      fila('Nombre', escaparHtml(datos.nombre)) +
      fila('Empresa', datos.empresa ? escaparHtml(datos.empresa) : 'No especificada') +
      fila('Correo', escaparHtml(datos.correo)) +
      fila('Teléfono', datos.telefono ? escaparHtml(datos.telefono) : 'No especificado') +
      '<div style="margin-top:25px;">' +
        '<strong>Mensaje:</strong>' +
        '<div style="margin-top:10px;padding:18px;background:#f5f5f5;border-left:3px solid #E71917;white-space:pre-wrap;">' +
          escaparHtml(datos.mensaje) +
        '</div>' +
      '</div>' +
      '<p style="margin-top:30px;font-size:12px;color:#888;">Mensaje enviado desde el formulario de contacto de Tic&rsquo;s Solutions.</p>' +
    '</div>';

  try {
    // Hay que esperarlo: Vercel congela la función apenas se responde, y un
    // envío a medio camino se corta sin llegar.
    await transporte.sendMail({
      from: '"Sitio Web TIC\'S Solutions" <' + SMTP_USER + '>',
      to: CONTACT_EMAIL,
      replyTo: datos.correo,          // responder en Gmail le contesta al visitante
      subject: 'Nueva consulta web - ' + datos.nombre,
      text: plano,
      html: html
    });
    await marcarConsulta(idConsulta, { email_sent: true });
  } catch (error) {
    // Detalle para los registros de Vercel: el código y la respuesta del
    // servidor son lo único que distingue una clave rechazada de una cuenta
    // bloqueada. Al navegador no le llega nada de esto.
    console.error('Error SMTP:', {
      message: error instanceof Error ? error.message : error,
      code: error && error.code,
      response: error && error.response,
      responseCode: error && error.responseCode
    });
    // Con la consulta guardada, el mensaje no se perdió: aparece en el panel
    // con el correo en "no enviado", que es la señal para revisar el SMTP.
    // Mandar a quien escribió a reintentar por WhatsApp cuando su mensaje ya
    // llegó solo genera un duplicado.
    if (idConsulta) {
      return res.status(200).json({ success: true, message: 'Consulta enviada correctamente.' });
    }
    return res.status(500).json({
      error: 'No pudimos enviar tu consulta en este momento. Intentá nuevamente.'
    });
  }

  // Acuse al visitante. Va después y aparte: si falla, la consulta ya llegó
  // igual y no tiene por qué enterarse de nada.
  try {
    await transporte.sendMail({
      from: '"Tic\'s Solutions" <' + SMTP_USER + '>',
      to: datos.correo,
      subject: 'Recibimos tu consulta | Tic\'s Solutions',
      text: 'Hola ' + datos.nombre + ',\n\n' +
            'Gracias por contactar con Tic\'s Solutions.\n\n' +
            'Recibimos correctamente tu consulta y nuestro equipo se va a poner en contacto con vos a la brevedad.\n\n' +
            'Tic\'s Solutions\nTecnología a tu alcance',
      html:
        '<div style="font-family:Arial,Helvetica,sans-serif;max-width:600px;margin:auto;color:#1D1E1E;">' +
          '<p>Hola ' + escaparHtml(datos.nombre) + ',</p>' +
          '<p>Gracias por contactar con Tic&rsquo;s Solutions.</p>' +
          '<p>Recibimos correctamente tu consulta y nuestro equipo se va a poner en contacto con vos a la brevedad.</p>' +
          '<p style="margin-top:26px;border-top:3px solid #E71917;padding-top:14px;">' +
            '<strong>Tic&rsquo;s Solutions</strong><br />' +
            '<span style="color:#666;">Tecnología a tu alcance</span>' +
          '</p>' +
        '</div>'
    });
    await marcarConsulta(idConsulta, { auto_reply_sent: true });
  } catch (error) {
    console.error('La consulta llegó, pero falló el acuse al visitante:', error);
  }

  return res.status(200).json({ success: true, message: 'Consulta enviada correctamente.' });
};
