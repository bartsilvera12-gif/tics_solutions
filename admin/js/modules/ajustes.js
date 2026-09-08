/* Tic's Solutions — configuración, administradores y actividad */
(function () {
  "use strict";

  var el = UI.el;

  /* ==================================================== configuración === */
  // Una sola fila en site_settings: los datos que se repiten en todo el sitio.
  App.modulo({
    id: "configuracion",
    titulo: "Configuración",
    sub: "Datos de la empresa, contacto y SEO general",
    grupo: "Ajustes",
    icono: "⚙",

    async render(nodo) {
      var cfg;
      try {
        var r = await sb.from("site_settings").select("*").limit(1).maybeSingle();
        if (r.error) throw r.error;
        cfg = r.data || {};
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      var grupos = [
        ["Empresa", [
          { nombre: "company_name", etiqueta: "Nombre" },
          { nombre: "tagline", etiqueta: "Eslogan" },
          { nombre: "years_experience", etiqueta: "Años de experiencia", tipo: "number" },
          { nombre: "location", etiqueta: "Ubicación" }
        ]],
        ["Contacto", [
          { nombre: "contact_name", etiqueta: "Persona de contacto" },
          { nombre: "contact_role", etiqueta: "Cargo" },
          { nombre: "contact_email", etiqueta: "Correo", tipo: "email",
            ayuda: "A esta dirección llegan las consultas del formulario." },
          { nombre: "contact_phone_display", etiqueta: "Teléfono visible" },
          { nombre: "contact_phone_e164", etiqueta: "Teléfono en formato internacional",
            marcador: "+595981171372" },
          { nombre: "whatsapp_number", etiqueta: "WhatsApp", marcador: "595981171372",
            ayuda: "Solo números, sin el signo más." }
        ]],
        ["Pie de página", [
          { nombre: "footer_text", etiqueta: "Texto del pie", ancho: "total" },
          { nombre: "developed_by_label", etiqueta: "Desarrollado por" },
          { nombre: "developed_by_url", etiqueta: "Enlace" }
        ]]
      ];

      UI.vaciar(nodo);

      var todos = [];
      grupos.forEach(function (g) { todos = todos.concat(g[1]); });

      var contenedor = el("div", { estilo: "max-width:840px" });
      grupos.forEach(function (g) {
        var tarjeta = el("div.tarjeta", { estilo: "margin-bottom:16px" }, [
          el("div.tarjeta-titulo", {}, [el("h2", { texto: g[0] })]),
          el("div.tarjeta-cuerpo", {}, [UI.formulario(g[1], cfg)])
        ]);
        contenedor.appendChild(tarjeta);
      });

      contenedor.appendChild(el("div", { estilo: "display:flex;justify-content:flex-end" }, [
        el("button.btn.btn-primario", {
          type: "button", texto: "Guardar cambios",
          onclick: async function () {
            var datos = UI.leerFormulario(contenedor, todos);

            if (datos.contact_email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(datos.contact_email)) {
              UI.error("El correo de contacto no tiene un formato válido.");
              return;
            }
            if (!UI.urlSegura(datos.developed_by_url)) {
              UI.error("Ese enlace no es válido.");
              return;
            }

            try {
              var r;
              if (cfg.id) {
                r = await sb.from("site_settings").update(datos).eq("id", cfg.id);
              } else {
                datos.singleton = true;
                r = await sb.from("site_settings").insert(datos);
              }
              if (r.error) throw r.error;
              UI.ok("Configuración guardada.");
            } catch (e) { UI.error(Auth.mensajeDeError(e)); }
          }
        })
      ]));

      nodo.appendChild(contenedor);
    }
  });

  /* =================================================== administradores == */
  App.modulo({
    id: "administradores",
    titulo: "Administradores",
    sub: "Quién puede entrar al panel",
    grupo: "Ajustes",
    icono: "◉",
    soloSuper: true,

    async render(nodo) {
      var filas;
      try {
        var r = await sb.from("admin_users").select("*").order("created_at");
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

      // Las cuentas se crean en Supabase, no acá: la contraseña la maneja
      // Auth y nunca pasa por este panel.
      nodo.appendChild(el("div.franja", {}, [
        el("span", { texto: "ℹ", "aria-hidden": "true" }),
        el("div", {}, [
          el("strong", { texto: "Las cuentas se crean en Supabase" }),
          el("span", { texto: "Authentication → Users → Add user, con «Auto Confirm User» marcado. " +
            "Después se le da permiso acá. La contraseña la guarda Supabase y no pasa por el panel." })
        ])
      ]));

      nodo.appendChild(el("div.tarjeta", {}, [
        UI.tabla([
          { titulo: "Administrador", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.full_name }),
                el("div.celda-secundaria", { texto: f.user_id })
              ]); } },
          { titulo: "Rol", celda: function (f) {
              return el("span.insignia." + (f.role === "super_admin" ? "insignia-nuevo" : "insignia-borrador"),
                        { texto: f.role === "super_admin" ? "Super admin" : "Editor" }); } },
          { titulo: "Activo", celda: function (f) {
              return f.is_active
                ? el("span.insignia.insignia-publicado", { texto: "Sí" })
                : el("span.insignia.insignia-archivado", { texto: "No" }); } },
          { titulo: "Último ingreso", celda: function (f) { return UI.fechaHora(f.last_login_at); } },
          { titulo: "", clase: "celda-acciones", celda: function (f) {
              var esYo = f.user_id === App.perfil.user_id;
              return el("div", { estilo: "display:inline-flex;gap:6px" }, [
                el("button.btn.btn-chico", {
                  type: "button", texto: "Editar", onclick: function () { editar(f); }
                }),
                // Nadie puede quitarse el acceso a sí mismo: dejaría el panel
                // sin super admin si es el único.
                esYo ? el("span.campo-ayuda", { texto: "sos vos" })
                     : el("button.btn.btn-chico" + (f.is_active ? ".btn-peligro" : ""), {
                         type: "button", texto: f.is_active ? "Desactivar" : "Activar",
                         onclick: function () { alternar(f); }
                       })
              ]); } }
        ], filas)
      ]));

      async function editar(f) {
        var campos = [
          { nombre: "full_name", etiqueta: "Nombre", requerido: true, ancho: "total" },
          { nombre: "role", etiqueta: "Rol", tipo: "select", opciones: [
              { valor: "editor", texto: "Editor — contenido" },
              { valor: "super_admin", texto: "Super admin — todo" }
            ] }
        ];
        var datos = await UI.modal({
          titulo: "Editar administrador",
          cuerpo: UI.formulario(campos, f),
          botones: [
            { texto: "Cancelar", alPulsar: function (c) { c(null); } },
            { texto: "Guardar", clase: "btn-primario", alPulsar: function (c, caja) {
                c(UI.leerFormulario(caja, campos)); } }
          ]
        });
        if (!datos) return;
        try {
          var r = await sb.from("admin_users").update(datos).eq("user_id", f.user_id);
          if (r.error) throw r.error;
          UI.ok("Administrador actualizado.");
          App.ir();
        } catch (e) { UI.error(Auth.mensajeDeError(e)); }
      }

      async function alternar(f) {
        var seguro = await UI.confirmar(
          f.is_active ? "Desactivar administrador" : "Activar administrador",
          f.is_active
            ? "«" + f.full_name + "» va a perder el acceso al panel."
            : "«" + f.full_name + "» va a poder entrar al panel.",
          f.is_active ? "Desactivar" : "Activar");
        if (!seguro) return;
        try {
          var r = await sb.from("admin_users")
            .update({ is_active: !f.is_active }).eq("user_id", f.user_id);
          if (r.error) throw r.error;
          UI.ok("Listo.");
          App.ir();
        } catch (e) { UI.error(Auth.mensajeDeError(e)); }
      }
    }
  });

  /* ======================================================== actividad === */
  App.modulo({
    id: "actividad",
    titulo: "Actividad",
    sub: "Qué se cambió y quién lo cambió",
    grupo: "Ajustes",
    icono: "◷",
    soloSuper: true,

    async render(nodo) {
      var filas;
      try {
        var r = await sb.from("audit_logs").select("*")
          .order("created_at", { ascending: false }).limit(200);
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

      if (!filas.length) {
        nodo.appendChild(el("div.tarjeta", {}, [
          UI.vacio("Sin movimientos todavía",
            "Acá queda registrado lo que se cree, edite, publique o elimine desde el panel.")
        ]));
        return;
      }

      nodo.appendChild(el("div.tarjeta", {}, [
        UI.tabla([
          { titulo: "Cuándo", ancho: "160px",
            celda: function (f) { return UI.fechaHora(f.created_at); } },
          { titulo: "Acción", celda: function (f) { return f.action; } },
          { titulo: "Dónde", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.entity_table || "—" }),
                el("div.celda-secundaria", { texto: f.entity_id || "" })
              ]); } }
        ], filas)
      ]));
    }
  });
})();
