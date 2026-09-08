/* Tic's Solutions — sesión del panel
 *
 * Estar autenticado NO alcanza para entrar. Cualquiera podría registrarse
 * contra el mismo proyecto de Supabase, que está compartido con más de cien
 * sitios de NEURA; lo que habilita este panel es tener fila activa en
 * ticspy.admin_users.
 *
 * Esta comprobación es de conveniencia: sirve para mostrar el panel o mandar
 * al ingreso. La protección real está en RLS: aunque alguien saltee esta
 * pantalla, Postgres le va a rechazar cualquier escritura.
 */
(function () {
  "use strict";

  var sb = window.sb;

  function mensajeDeError(e) {
    var m = (e && e.message) || "";
    if (/Invalid login credentials/i.test(m)) return "Correo o contraseña incorrectos.";
    if (/Email not confirmed/i.test(m)) return "La cuenta todavía no está confirmada.";
    if (/rate limit|too many/i.test(m)) return "Demasiados intentos. Esperá un momento.";
    if (/fetch|network|Failed to fetch/i.test(m)) return "No se pudo conectar con el servidor.";
    if (/PGRST106|Invalid schema/i.test(m)) {
      return "El schema ticspy todavía no está expuesto en PostgREST. Ver supabase/EXPONER_TICSPY.md.";
    }
    return m || "No se pudo completar la operación.";
  }

  var Auth = {
    perfil: null,

    // Devuelve el perfil de administrador si la sesión es válida, o null.
    // Si hay sesión pero no es administrador, la cierra: dejarla abierta
    // solo confunde a quien vuelve a intentar.
    async verificar() {
      var ses = await sb.auth.getSession();
      if (!ses.data.session) return null;

      var r = await sb
        .from("admin_users")
        .select("user_id, full_name, role, is_active")
        .eq("user_id", ses.data.session.user.id)
        .maybeSingle();

      if (r.error) {
        // Un fallo de red o de PostgREST no es lo mismo que no ser
        // administrador: se propaga para poder explicarlo.
        r.error.esDeRed = true;
        throw r.error;
      }
      if (!r.data || !r.data.is_active) {
        await sb.auth.signOut();
        return null;
      }

      r.data.email = ses.data.session.user.email;
      this.perfil = r.data;
      return r.data;
    },

    async ingresar(email, password) {
      var r = await sb.auth.signInWithPassword({ email: email, password: password });
      if (r.error) {
        // Supabase devuelve el mismo error para usuario inexistente y
        // contraseña incorrecta, a propósito. No se afina el mensaje:
        // distinguirlos permitiría averiguar qué correos existen.
        return { ok: false, mensaje: mensajeDeError(r.error) };
      }

      var perfil;
      try {
        perfil = await this.verificar();
      } catch (e) {
        await sb.auth.signOut();
        return { ok: false, mensaje: mensajeDeError(e) };
      }

      if (!perfil) {
        return { ok: false, mensaje: "Esta cuenta no tiene acceso al panel." };
      }

      // Marca de último ingreso. Si falla no se corta: es informativa.
      try {
        await sb.from("admin_users")
          .update({ last_login_at: new Date().toISOString() })
          .eq("user_id", perfil.user_id);
      } catch (e) { /* sin consecuencias */ }

      return { ok: true, perfil: perfil };
    },

    async salir() {
      try { await sb.auth.signOut(); } catch (e) { /* igual se sale */ }
      location.href = "/admin/login";
    },

    esSuperAdmin() {
      return !!(this.perfil && this.perfil.role === "super_admin");
    },

    mensajeDeError: mensajeDeError
  };

  window.Auth = Auth;
})();
