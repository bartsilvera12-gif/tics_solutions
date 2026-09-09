/* Tic's Solutions — consultas recibidas
 *
 * Lo que llega por el formulario del sitio. El correo se sigue mandando por
 * SMTP como siempre; esto es el registro, para no depender de la bandeja de
 * entrada y para poder marcar qué se respondió.
 */
(function () {
  "use strict";

  var el = UI.el;

  // El mismo control que hace el formulario del sitio antes de guardar. Se
  // repite acá porque una fila vieja puede traer cualquier cosa en el campo.
  var CORREO_VALIDO = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  // La casilla de la empresa, la misma desde la que sale el correo del
  // formulario. Se lee de Ajustes para no tenerla escrita en dos lugares, y
  // se recuerda para no volver a pedirla cada vez que se abre una ficha.
  var CASILLA_POR_DEFECTO = "arturo.osorio@tics-py.com";
  var casillaEmpresa = null;

  async function traerCasilla() {
    if (casillaEmpresa) return casillaEmpresa;
    var v = "";
    try {
      var r = await sb.from("site_settings").select("contact_email").limit(1).maybeSingle();
      v = r.data ? String(r.data.contact_email || "").trim() : "";
    } catch (e) { /* si no se puede leer, queda la de siempre */ }
    casillaEmpresa = CORREO_VALIDO.test(v) ? v : CASILLA_POR_DEFECTO;
    return casillaEmpresa;
  }

  var ESTADOS = [
    { valor: "new",      texto: "Nueva" },
    { valor: "read",     texto: "Leída" },
    { valor: "replied",  texto: "Respondida" },
    { valor: "archived", texto: "Archivada" },
    { valor: "spam",     texto: "Spam" }
  ];

  // Queda escrita pero SIN registrar, como el resto de las que se ocultaron.
  //
  // Las consultas se siguen guardando y se siguen mandando por correo a la
  // casilla de la empresa: eso lo hace la función del formulario, que no pasa
  // por acá. Lo que se saca es la pantalla que las lista.
  //
  // Para volver a colgarla, pasarle este objeto a App.modulo.
  var MODULO_CONSULTAS = {
    id: "consultas",
    titulo: "Consultas",
    sub: "Lo que llega por el formulario del sitio",
    grupo: "General",
    icono: "✉",

    async render(nodo) {
      var filtro = sessionStorage.getItem("ticspy.consultas.filtro") || "todas";
      var filas;

      try {
        var q = sb.from("contact_submissions").select("*")
          .order("created_at", { ascending: false }).limit(300);
        if (filtro !== "todas") q = q.eq("status", filtro);
        var r = await q;
        if (r.error) throw r.error;
        filas = r.data;
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      UI.vaciar(nodo);

      var barra = el("div.pestanas");
      [["todas", "Todas"]].concat(ESTADOS.map(function (e) { return [e.valor, e.texto + "s"]; }))
        .forEach(function (p) {
          barra.appendChild(el("button.pestana" + (p[0] === filtro ? ".activa" : ""), {
            type: "button", texto: p[1],
            onclick: function () {
              sessionStorage.setItem("ticspy.consultas.filtro", p[0]);
              App.ir();
            }
          }));
        });
      nodo.appendChild(barra);

      if (!filas.length) {
        nodo.appendChild(el("div.tarjeta", {}, [
          UI.vacio("Sin consultas",
            filtro === "todas"
              ? "Cuando alguien complete el formulario del sitio, va a aparecer acá."
              : "No hay consultas en este estado.")
        ]));
        return;
      }

      nodo.appendChild(el("div.tarjeta", {}, [
        UI.tabla([
          { titulo: "Fecha", ancho: "150px",
            celda: function (f) { return UI.fechaHora(f.created_at); } },
          { titulo: "Quién", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.name }),
                el("div.celda-secundaria", { texto: [f.company, f.email].filter(Boolean).join(" · ") })
              ]); } },
          { titulo: "Teléfono", celda: function (f) { return f.phone || "—"; } },
          { titulo: "Correo enviado", celda: function (f) {
              // Si la consulta quedó guardada pero el correo falló, hay que
              // verlo de un vistazo: si no, nadie se entera.
              return f.email_sent
                ? el("span.insignia.insignia-publicado", { texto: "Sí" })
                : el("span.insignia.insignia-archivado", { texto: "No" }); } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } },
          { titulo: "", clase: "celda-acciones", celda: function (f) {
              return el("button.btn.btn-chico", {
                type: "button", texto: "Ver",
                onclick: function () { abrir(f); }
              }); } }
        ], filas)
      ]));

      /* -------------------------------------------------------- ficha -- */
      async function abrir(c) {
        var casilla = await traerCasilla();

        // Abrirla ya cuenta como leerla.
        if (c.status === "new") {
          try {
            await sb.from("contact_submissions")
              .update({ status: "read", read_at: new Date().toISOString() })
              .eq("id", c.id);
          } catch (e) { /* no impide leerla */ }
        }

        function dato(etiqueta, valor) {
          return el("div", { estilo: "margin-bottom:12px" }, [
            el("p.rotulo", { texto: etiqueta }),
            el("div", { texto: valor || "—", estilo: "font-weight:600" })
          ]);
        }

        var campos = [
          { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
          { nombre: "internal_notes", etiqueta: "Notas internas", tipo: "textarea", ancho: "total",
            ayuda: "Solo se ven acá. No se le mandan a quien escribió." }
        ];

        var cuerpo = el("div", {}, [
          el("div.rejilla", {}, [
            dato("Nombre", c.name), dato("Empresa", c.company),
            dato("Correo", c.email), dato("Teléfono", c.phone)
          ]),
          el("p.rotulo", { texto: "Mensaje" }),
          el("div", {
            texto: c.message,
            estilo: "white-space:pre-wrap;background:#FAFAFB;border:1px solid var(--linea);" +
                    "border-left:3px solid var(--rojo);border-radius:8px;padding:14px;margin:6px 0 20px"
          }),
          el("p.campo-ayuda", {
            texto: "Recibida el " + UI.fechaHora(c.created_at) +
                   (c.source_route ? " desde " + c.source_route : "") +
                   " · correo al equipo: " + (c.email_sent ? "enviado" : "no enviado") +
                   " · acuse al visitante: " + (c.auto_reply_sent ? "enviado" : "no enviado")
          }),
          UI.formulario(campos, c)
        ]);

        var accion = await UI.modal({
          titulo: "Consulta de " + c.name,
          ancho: true,
          cuerpo: cuerpo,
          botones: [
            { texto: "Responder por correo", alPulsar: function (cerrar, caja) {
                // Abre Gmail en el navegador con el destinatario, el asunto y
                // el saludo ya puestos. No manda nada: queda en pantalla para
                // revisar y tocar Enviar dentro de Gmail.
                //
                // Antes esto era un mailto, que en Windows abre Outlook.
                var correo = String(c.email || "").trim();
                if (!CORREO_VALIDO.test(correo)) {
                  UI.error("Esta consulta no tiene un correo válido para responder.");
                  return;
                }

                var asunto = "Re: Consulta web - " + c.name;
                var saludo = "Hola " + c.name + ",\n\n" +
                             "Gracias por comunicarte con TIC'S Solutions.\n\n";

                // El tramo /u/<casilla>/ le dice a Gmail desde qué cuenta
                // redactar. Sin eso escribe desde la sesión que haya abierta
                // en el navegador, que puede ser la cuenta personal de quien
                // administra: la respuesta le llegaría al cliente firmada por
                // un correo que no es el de la empresa. La casilla ya pasó por
                // CORREO_VALIDO, así que no puede traer una barra ni un signo
                // de pregunta que rompa la dirección.
                var url = "https://mail.google.com/mail/u/" + casilla + "/?view=cm&fs=1" +
                  "&to=" + encodeURIComponent(correo) +
                  "&su=" + encodeURIComponent(asunto) +
                  "&body=" + encodeURIComponent(saludo);

                // La pestaña se abre sin poner 'noopener' entre las opciones a
                // propósito: con esa palabra el navegador devuelve null aunque
                // la haya abierto bien, y no quedaría forma de distinguir eso
                // de una pestaña bloqueada. Se corta la referencia después, que
                // deja el mismo aislamiento.
                var pestana = window.open(url, "_blank");
                if (pestana) {
                  try { pestana.opener = null; } catch (e) { /* ya se abrió igual */ }
                } else {
                  // Solo si el navegador bloqueó la pestaña. Vuelve al cliente
                  // de correo del sistema, que es lo que se quería evitar, pero
                  // es mejor que dejar el botón sin hacer nada.
                  UI.aviso("El navegador bloqueó la pestaña de Gmail. Se abre el correo del sistema.");
                  location.href = "mailto:" + encodeURIComponent(correo) +
                    "?subject=" + encodeURIComponent(asunto) +
                    "&body=" + encodeURIComponent(saludo);
                }

                cerrar({ datos: UI.leerFormulario(caja, campos), responder: true });
              } },
            { texto: "Cancelar", alPulsar: function (cerrar) { cerrar(null); } },
            { texto: "Guardar", clase: "btn-primario", alPulsar: function (cerrar, caja) {
                cerrar({ datos: UI.leerFormulario(caja, campos) }); } }
          ]
        });

        if (!accion) { App.ir(); return; }

        var datos = accion.datos;
        if (accion.responder && datos.status === "read") {
          datos.status = "replied";
        }
        if (datos.status === "replied" && !c.replied_at) {
          datos.replied_at = new Date().toISOString();
        }

        try {
          var r = await sb.from("contact_submissions").update(datos).eq("id", c.id);
          if (r.error) throw r.error;
          await Auth.anotar("update", "contact_submissions", c.id, { estado: datos.status });
          UI.ok("Consulta actualizada.");
        } catch (e) { UI.error(Auth.mensajeDeError(e)); }
        App.ir();
      }
    }
  };
  void MODULO_CONSULTAS;
})();
