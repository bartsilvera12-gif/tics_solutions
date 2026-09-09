/* Tic's Solutions — configuración de Supabase (pública)
 *
 * Lo de este archivo va al navegador y es visible para cualquiera. Está
 * bien: la anon key está diseñada para eso. Lo que impide que un visitante
 * escriba en la base no es esconder esta clave, sino las políticas RLS de
 * Postgres (supabase/migrations/004_ticspy_rls.sql).
 *
 * NUNCA agregar acá la service_role key, la contraseña de Postgres ni la
 * clave SMTP. La service_role se saltea RLS por completo: si llega al
 * navegador, cualquier persona puede borrar el sitio entero.
 */
window.TICS_CONFIG = {
  SUPABASE_URL: "https://api.neura.com.py",

  // Rol `anon`. Pública por diseño.
  SUPABASE_ANON_KEY:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc0MTAxNDYxLCJleHAiOjE5MzE3ODE0NjF9.7_wAph8IolPMXtgfpezSwS5XR62IdD__qhqCywLDp3Q",

  // Todas las tablas del sitio viven acá, nunca en `public`: la instancia
  // está compartida con más de cien proyectos de NEURA.
  SCHEMA: "ticspy",

  // Bucket de Storage para lo que se suba desde el panel.
  BUCKET: "tics-media",

  // Los 58 archivos que ya están en el repositorio se siguen sirviendo desde
  // el sitio con rutas relativas. Lo que se suba desde el panel queda como
  // URL absoluta de Storage y no pasa por acá.
  IMAGE_BASE: "/",

  // A dónde manda el formulario de contacto.
  //
  // Vacío significa "el mismo servidor que sirve la página", que es lo que
  // corresponde en Vercel: ahí /api/contact es una función que corre del lado
  // del servidor. Hostinger solo sirve archivos y no ejecuta nada, así que
  // para ese despliegue hay que poner la dirección completa de la función.
  // Eso lo hace solo tools/construir-dist.ps1 al armar dist/.
  API_CONTACT: ""
};
