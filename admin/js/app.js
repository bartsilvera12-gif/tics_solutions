/* Tic's Solutions — armazón del panel
 *
 * Cada sección se registra con App.modulo(). El orden de registro define el
 * orden del menú, así que el orden de los <script> en index.html importa.
 */
(function () {
  "use strict";

  var modulos = [];
  var contenedorVista = null;

  var App = {
    perfil: null,

    // { id, titulo, grupo, icono, soloSuper, render(nodo) }
    modulo: function (def) { modulos.push(def); },

    /* ---------------------------------------------------------- inicio -- */
    async iniciar() {
      var perfil;
      try {
        perfil = await Auth.verificar();
      } catch (e) {
        // La API caída no es lo mismo que no tener permiso: si mandáramos al
        // ingreso, ahí volvería a fallar y quedaría un rebote sin explicación.
        this.pantallaDeError(Auth.mensajeDeError(e));
        return;
      }

      if (!perfil) { location.replace("/admin/login"); return; }

      this.perfil = perfil;
      this.pintarArmazon();
      window.addEventListener("hashchange", function () { App.ir(); });
      this.ir();
    },

    pantallaDeError: function (mensaje) {
      var app = document.getElementById("app");
      UI.vaciar(app);
      app.appendChild(UI.el("div", { estilo: "max-width:56ch;margin:12vh auto;padding:24px" }, [
        UI.el("p.rotulo", { texto: "No se pudo abrir el panel" }),
        UI.el("h1", { texto: "Falta un paso de configuración",
                      estilo: "font-size:24px;font-weight:600;margin:8px 0 12px" }),
        UI.el("div.aviso.aviso-error", { texto: mensaje }),
        UI.el("a.btn", { href: "/admin/login", texto: "Volver al ingreso" })
      ]));
    },

    /* -------------------------------------------------------- armazón -- */
    pintarArmazon: function () {
      var app = document.getElementById("app");
      UI.vaciar(app);

      var visibles = modulos.filter(function (m) {
        return !m.soloSuper || Auth.esSuperAdmin();
      });

      // --- lateral ---
      var nav = UI.el("nav");
      var grupoActual = null;
      visibles.forEach(function (m) {
        if (m.grupo && m.grupo !== grupoActual) {
          grupoActual = m.grupo;
          nav.appendChild(UI.el("div.lateral-grupo", { texto: m.grupo }));
        }
        nav.appendChild(UI.el("a", {
          href: "#/" + m.id,
          dataset: { modulo: m.id },
          onclick: function () { App.cerrarCajon(); }
        }, [
          UI.el("span.icono", { texto: m.icono || "•", "aria-hidden": "true" }),
          UI.el("span", { texto: m.titulo }),
          UI.el("span.contador", { dataset: { contador: m.id }, hidden: true })
        ]));
      });

      var lateral = UI.el("aside.lateral#lateral", {}, [
        UI.el("div.lateral-marca", {}, [
          UI.el("span.marca-panel", { texto: "Tic’s Solutions" }),
          UI.el("small", { texto: "Panel de gestión" })
        ]),
        nav,
        UI.el("div.lateral-pie", {}, [
          UI.el("div.quien", { texto: this.perfil.full_name || this.perfil.email }),
          UI.el("div.rol", { texto: this.perfil.role === "super_admin" ? "Super administrador" : "Editor" }),
          UI.el("button", { type: "button", texto: "Cerrar sesión",
                            onclick: function () { Auth.salir(); } })
        ])
      ]);

      // --- barra superior ---
      var barra = UI.el("header.barra", {}, [
        UI.el("button.hamburguesa", {
          type: "button", "aria-label": "Abrir menú", texto: "☰",
          onclick: function () { App.alternarCajon(); }
        }),
        UI.el("div", {}, [
          UI.el("h1#tituloVista", { texto: "" }),
          UI.el("p.sub#subVista", { texto: "" })
        ]),
        UI.el("div.acciones#accionesVista")
      ]);

      contenedorVista = UI.el("div.vista.trama#vista");

      app.appendChild(UI.el("div.panel", {}, [
        lateral,
        UI.el("div.contenido", {}, [barra, contenedorVista])
      ]));
    },

    /* ---------------------------------------------------------- cajón -- */
    alternarCajon: function () {
      var l = document.getElementById("lateral");
      if (!l) return;
      var abierta = l.classList.toggle("abierta");
      var velo = document.getElementById("velo");
      if (abierta && !velo) {
        velo = UI.el("div.velo#velo", { onclick: function () { App.cerrarCajon(); } });
        document.body.appendChild(velo);
      } else if (!abierta && velo) {
        velo.parentNode.removeChild(velo);
      }
    },

    cerrarCajon: function () {
      var l = document.getElementById("lateral");
      if (l) l.classList.remove("abierta");
      var velo = document.getElementById("velo");
      if (velo) velo.parentNode.removeChild(velo);
    },

    /* --------------------------------------------------------- ruteo --- */
    ir: function () {
      var id = (location.hash || "").replace(/^#\/?/, "") || modulos[0].id;
      var m = modulos.filter(function (x) { return x.id === id; })[0];

      if (!m || (m.soloSuper && !Auth.esSuperAdmin())) {
        m = modulos[0];
        id = m.id;
      }

      document.querySelectorAll(".lateral a").forEach(function (a) {
        a.classList.toggle("activo", a.dataset.modulo === id);
      });

      this.titulo(m.titulo, m.sub || "");
      UI.vaciar(document.getElementById("accionesVista"));
      UI.vaciar(contenedorVista);
      contenedorVista.appendChild(UI.esqueleto(3));

      Promise.resolve()
        .then(function () { return m.render(contenedorVista); })
        .catch(function (e) {
          UI.vaciar(contenedorVista);
          contenedorVista.appendChild(
            UI.el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
          console.error("[panel] " + id, e);
        });
    },

    titulo: function (t, sub) {
      document.getElementById("tituloVista").textContent = t;
      document.getElementById("subVista").textContent = sub || "";
      document.title = t + " — Panel de Tic's Solutions";
    },

    accion: function (nodo) {
      document.getElementById("accionesVista").appendChild(nodo);
    },

    contador: function (id, n) {
      var c = document.querySelector('[data-contador="' + id + '"]');
      if (!c) return;
      if (n > 0) { c.textContent = n; c.hidden = false; }
      else c.hidden = true;
    },

    /* ------------------------------------------------- estado del CMS -- */
    // Mientras ticspy no esté expuesto en PostgREST, toda consulta falla con
    // PGRST106. Conviene decirlo una vez y con todas las letras, en vez de
    // dejar doce pantallas con el mismo error críptico.
    franjaSiFalta: function (nodo, error) {
      if (!error) return false;
      var m = (error.message || "") + (error.code || "");
      if (!/PGRST106|Invalid schema|does not exist/i.test(m)) return false;
      nodo.appendChild(UI.el("div.franja", {}, [
        UI.el("span", { texto: "⚠", "aria-hidden": "true" }),
        UI.el("div", {}, [
          UI.el("strong", { texto: "El CMS todavía no está conectado" }),
          UI.el("span", { texto: "El schema ticspy no está expuesto en PostgREST. " +
            "Las tablas y el contenido ya existen; falta agregar ticspy a PGRST_DB_SCHEMAS " +
            "en el servidor. El instructivo está en supabase/EXPONER_TICSPY.md." })
        ])
      ]));
      return true;
    }
  };

  window.App = App;
})();
