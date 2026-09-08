/* Tic's Solutions — cliente de Supabase para el panel
 *
 * A diferencia del sitio público, el panel sí usa la librería oficial:
 * necesita sesiones, refresco automático del token y subida a Storage.
 *
 * SOLO se usa la anon key. La service_role NUNCA entra acá: se saltea RLS
 * por completo, y todo lo que este archivo carga termina en el navegador de
 * quien abra el panel. Que alguien pueda editar el sitio lo decide RLS a
 * partir de su sesión, no esta clave.
 */
(function () {
  "use strict";

  var cfg = window.TICS_CONFIG;
  if (!cfg) throw new Error("Falta js/config.js");
  if (!window.supabase || !window.supabase.createClient) {
    throw new Error("No cargó la librería de Supabase");
  }

  var cliente = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: false,
      // Propia del sitio: si mañana se abre otro panel de NEURA en el mismo
      // navegador, las sesiones no se pisan entre sí.
      storageKey: "ticspy.admin.auth"
    },
    // Todas las consultas del panel van al schema del sitio, nunca a public.
    db: { schema: cfg.SCHEMA }
  });

  window.sb = cliente;

  // Storage vive fuera del schema, así que se expone aparte para no
  // confundirlo con las tablas.
  window.sbStorage = cliente.storage.from(cfg.BUCKET);
})();
