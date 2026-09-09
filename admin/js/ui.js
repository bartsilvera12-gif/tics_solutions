/* Tic's Solutions — utilidades de interfaz del panel
 *
 * Todo se arma con createElement y textContent. En ningún punto se
 * construye HTML concatenando strings con datos: el contenido lo escriben
 * personas desde el panel, y un nombre con "<" no puede terminar ejecutando
 * nada en la pantalla del siguiente que entre.
 */
(function () {
  "use strict";

  /* --------------------------------------------------------- elementos -- */

  // el("div.clase#id", {attr}, [hijos]) -> HTMLElement
  function el(sel, props, hijos) {
    var partes = String(sel).split(/(?=[.#])/);
    var nodo = document.createElement(partes[0] || "div");
    partes.slice(1).forEach(function (p) {
      if (p[0] === ".") nodo.classList.add(p.slice(1));
      else if (p[0] === "#") nodo.id = p.slice(1);
    });
    props = props || {};
    Object.keys(props).forEach(function (k) {
      var v = props[k];
      if (v === null || v === undefined || v === false) return;
      if (k === "texto") nodo.textContent = v;
      else if (k === "estilo") nodo.setAttribute("style", v);
      else if (k.slice(0, 2) === "on") nodo.addEventListener(k.slice(2), v);
      else if (k === "dataset") Object.keys(v).forEach(function (d) { nodo.dataset[d] = v[d]; });
      else if (k in nodo && k !== "list") nodo[k] = v;
      else nodo.setAttribute(k, v);
    });
    (hijos || []).forEach(function (h) {
      if (h === null || h === undefined || h === false) return;
      nodo.appendChild(typeof h === "string" ? document.createTextNode(h) : h);
    });
    return nodo;
  }

  function vaciar(nodo) { while (nodo.firstChild) nodo.removeChild(nodo.firstChild); }

  /* ------------------------------------------------------------ avisos -- */

  var pila = null;

  function flotante(texto, tipo) {
    if (!pila) {
      pila = el("div.avisos-flotantes", { role: "status", "aria-live": "polite" });
      document.body.appendChild(pila);
    }
    var n = el("div.flotante" + (tipo ? ".flotante-" + tipo : ""), { texto: texto });
    pila.appendChild(n);
    setTimeout(function () {
      n.style.transition = "opacity .25s ease";
      n.style.opacity = "0";
      setTimeout(function () { if (n.parentNode) n.parentNode.removeChild(n); }, 260);
    }, tipo === "error" ? 6000 : 3200);
  }

  var UI = {
    el: el,
    vaciar: vaciar,
    ok: function (t) { flotante(t, "ok"); },
    error: function (t) { flotante(t, "error"); },
    aviso: function (t) { flotante(t); },

    /* ---------------------------------------------------------- modal -- */
    // Devuelve una promesa: resuelve con lo que pase `cerrar`.
    modal: function (opciones) {
      return new Promise(function (resolver) {
        var fondo = el("div.fondo-modal");
        var caja = el("div.modal" + (opciones.ancho ? ".modal-ancho" : ""), {
          role: "dialog", "aria-modal": "true", "aria-label": opciones.titulo || "Diálogo"
        });

        function cerrar(valor) {
          document.removeEventListener("keydown", alTeclado);
          if (fondo.parentNode) fondo.parentNode.removeChild(fondo);
          resolver(valor);
        }

        function alTeclado(ev) {
          // Con dos diálogos abiertos (elegir una imagen desde una ficha),
          // Escape tiene que cerrar solo el de arriba. Sin esto cerraba los
          // dos y se perdía lo que se estaba escribiendo en la ficha.
          var abiertos = document.querySelectorAll(".fondo-modal");
          if (abiertos.length && abiertos[abiertos.length - 1] !== fondo) return;
          if (ev.key === "Escape") cerrar(null);
          // El foco no debe escaparse del diálogo mientras está abierto.
          if (ev.key === "Tab") {
            var foco = caja.querySelectorAll(
              'a[href],button:not([disabled]),input:not([disabled]),select,textarea,[tabindex]:not([tabindex="-1"])');
            if (!foco.length) return;
            var primero = foco[0], ultimo = foco[foco.length - 1];
            if (ev.shiftKey && document.activeElement === primero) { ev.preventDefault(); ultimo.focus(); }
            else if (!ev.shiftKey && document.activeElement === ultimo) { ev.preventDefault(); primero.focus(); }
          }
        }

        var cabecera = el("div.modal-cabecera", {}, [
          el("h2", { texto: opciones.titulo || "" }),
          el("button.cerrar", { type: "button", "aria-label": "Cerrar", texto: "×",
                                onclick: function () { cerrar(null); } })
        ]);

        var cuerpo = el("div.modal-cuerpo");
        if (opciones.cuerpo) cuerpo.appendChild(opciones.cuerpo);

        var pie = el("div.modal-pie");
        (opciones.botones || []).forEach(function (b) {
          pie.appendChild(el("button.btn" + (b.clase ? "." + b.clase : ""), {
            type: "button", texto: b.texto,
            onclick: function () { b.alPulsar ? b.alPulsar(cerrar, caja) : cerrar(b.valor); }
          }));
        });

        caja.appendChild(cabecera);
        caja.appendChild(cuerpo);
        if (pie.childNodes.length) caja.appendChild(pie);
        fondo.appendChild(caja);

        fondo.addEventListener("mousedown", function (ev) {
          if (ev.target === fondo) cerrar(null);
        });
        document.addEventListener("keydown", alTeclado);
        document.body.appendChild(fondo);

        var primerCampo = caja.querySelector("input,textarea,select,button");
        if (primerCampo) primerCampo.focus();
      });
    },

    /* ------------------------------------------------------ confirmar -- */
    // Nunca se borra nada sin pasar por acá.
    confirmar: function (titulo, texto, textoBoton) {
      return UI.modal({
        titulo: titulo,
        cuerpo: el("p", { texto: texto, estilo: "margin:0;color:var(--gris-fuerte)" }),
        botones: [
          { texto: "Cancelar", alPulsar: function (c) { c(false); } },
          { texto: textoBoton || "Eliminar", clase: "btn-peligro",
            alPulsar: function (c) { c(true); } }
        ]
      }).then(function (v) { return v === true; });
    },

    /* -------------------------------------------------------- insignia -- */
    /* ------------------------------------------------------ etiquetas -- */
    // El registro de actividad guarda nombres técnicos, que son los correctos
    // para buscar pero no para leer. Viven acá y no en una pantalla porque
    // los usa más de una.
    ACCIONES: {
      create: "Creó", update: "Editó", delete: "Eliminó",
      publish: "Publicó", unpublish: "Ocultó",
      login: "Entró", logout: "Salió", upload: "Subió un archivo"
    },

    DONDE: {
      pages: "Páginas", page_sections: "Textos de las páginas",
      services: "Servicios", solutions: "Soluciones",
      solution_features: "Fichas de soluciones", solution_demos: "Videos de soluciones",
      brands: "Partners y marcas", news_items: "Novedades",
      contact_submissions: "Consultas", site_settings: "Configuración",
      admin_users: "Administradores", media_assets: "Multimedia",
      navigation_items: "Navegación"
    },

    insignia: function (estado) {
      var mapa = {
        published: ["publicado", "Publicado"],
        draft: ["borrador", "Borrador"],
        archived: ["archivado", "Archivado"],
        new: ["nuevo", "Nueva"],
        read: ["borrador", "Leída"],
        replied: ["publicado", "Respondida"],
        spam: ["archivado", "Spam"]
      };
      var m = mapa[estado] || ["borrador", estado || "—"];
      return el("span.insignia.insignia-" + m[0], { texto: m[1] });
    },

    /* ---------------------------------------------------------- vacío -- */
    vacio: function (titulo, texto, accion) {
      return el("div.vacio", {}, [
        el("div.simbolo", { texto: "◫" }),
        el("h3", { texto: titulo }),
        el("p", { texto: texto }),
        accion || null
      ]);
    },

    esqueleto: function (filas) {
      var caja = el("div", { estilo: "padding:22px;display:flex;flex-direction:column;gap:12px" });
      for (var i = 0; i < (filas || 4); i++) {
        caja.appendChild(el("div.esqueleto", {
          estilo: "width:" + (58 + Math.round(Math.random() * 38)) + "%"
        }));
      }
      return caja;
    },

    /* --------------------------------------------------------- tabla --- */
    // columnas: [{ titulo, celda(fila) -> nodo|string, ancho }]
    tabla: function (columnas, filas, opciones) {
      opciones = opciones || {};
      var thead = el("thead", {}, [
        el("tr", {}, columnas.map(function (c) {
          return el("th", { texto: c.titulo || "", estilo: c.ancho ? "width:" + c.ancho : null });
        }))
      ]);

      var tbody = el("tbody");
      filas.forEach(function (f) {
        var tr = el("tr", { dataset: { id: f.id || "" } });
        columnas.forEach(function (c) {
          var v = c.celda ? c.celda(f) : "";
          tr.appendChild(el("td" + (c.clase ? "." + c.clase : ""), {},
            [typeof v === "string" ? document.createTextNode(v) : v]));
        });
        tbody.appendChild(tr);
      });

      return el("div.tabla-marco", {}, [el("table.tabla", {}, [thead, tbody])]);
    },

    /* --------------------------------------------------------- campos -- */
    // campos: [{ nombre, etiqueta, tipo, ayuda, opciones, ancho }]
    // tipo "imagen" guarda el id de media_assets y muestra la miniatura.
    formulario: function (campos, valores) {
      valores = valores || {};
      var rejilla = el("div.rejilla");

      campos.forEach(function (c) {
        var v = valores[c.nombre];
        var control;

        if (c.tipo === "textarea") {
          control = el("textarea", { name: c.nombre, rows: c.filas || 4 });
          control.value = v == null ? "" : v;
        } else if (c.tipo === "select") {
          control = el("select", { name: c.nombre });
          (c.opciones || []).forEach(function (o) {
            control.appendChild(el("option", { value: o.valor, texto: o.texto,
                                               selected: String(v) === String(o.valor) }));
          });
        } else if (c.tipo === "imagen") {
          // La miniatura y el botón son la interfaz; el valor viaja en un
          // campo oculto para que leerFormulario lo encuentre como a
          // cualquier otro.
          var oculto = el("input", { type: "hidden", name: c.nombre });
          oculto.value = v == null ? "" : v;

          var vista = el("div", { estilo: "display:flex;align-items:center;gap:12px" });
          var refrescar = function () {
            UI.vaciar(vista);
            vista.appendChild(Media.mini(oculto.value || null, c.etiqueta));
            vista.appendChild(el("button.btn.btn-chico", {
              type: "button",
              texto: oculto.value ? "Cambiar" : "Elegir",
              onclick: async function () {
                var r = await Media.elegir(oculto.value || null, c.soloVideo);
                if (!r) return;                 // canceló
                oculto.value = r.id || "";
                refrescar();
              }
            }));
            vista.appendChild(oculto);
          };
          refrescar();

          rejilla.appendChild(el("div.campo" + (c.ancho === "total" ? ".ancho-total" : ""), {}, [
            el("span", { texto: c.etiqueta }),
            vista,
            c.ayuda ? el("p.campo-ayuda", { texto: c.ayuda }) : null
          ]));
          return;

        } else if (c.tipo === "interruptor") {
          var entrada = el("input", { type: "checkbox", name: c.nombre, checked: !!v });
          var etiqueta = el("label.interruptor", {}, [
            entrada,
            el("span.interruptor-pista"),
            el("span", { texto: c.etiqueta, estilo: "font-size:14px;font-weight:600" })
          ]);
          var envoltorio = el("div.campo" + (c.ancho === "total" ? ".ancho-total" : ""), {}, [
            etiqueta,
            c.ayuda ? el("p.campo-ayuda", { texto: c.ayuda }) : null
          ]);
          rejilla.appendChild(envoltorio);
          return;
        } else {
          control = el("input", { type: c.tipo || "text", name: c.nombre,
                                  placeholder: c.marcador || "" });
          control.value = v == null ? "" : v;
        }

        rejilla.appendChild(el("label.campo" + (c.ancho === "total" ? ".ancho-total" : ""), {}, [
          el("span", { texto: c.etiqueta }),
          control,
          c.ayuda ? el("p.campo-ayuda", { texto: c.ayuda }) : null
        ]));
      });

      return rejilla;
    },

    // Lee un formulario armado con UI.formulario.
    leerFormulario: function (raiz, campos) {
      var datos = {};
      campos.forEach(function (c) {
        var n = raiz.querySelector('[name="' + c.nombre + '"]');
        if (!n) return;
        if (c.tipo === "interruptor") datos[c.nombre] = n.checked;
        else if (c.tipo === "number") datos[c.nombre] = n.value === "" ? null : Number(n.value);
        else datos[c.nombre] = n.value.trim() === "" ? null : n.value.trim();
      });
      return datos;
    },

    /* ------------------------------------------------------ validación -- */
    // Un enlace administrable no puede ejecutar código: se bloquean los
    // esquemas que sirven para eso.
    urlSegura: function (u) {
      if (!u) return true;
      var s = String(u).trim().toLowerCase().replace(/[\s -]/g, "");
      return !/^(javascript|data|vbscript|file):/.test(s);
    },

    slug: function (t) {
      return String(t || "")
        .normalize("NFD").replace(/[̀-ͯ]/g, "")
        .toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 60);
    },

    peso: function (bytes) {
      if (!bytes) return "—";
      if (bytes < 1024) return bytes + " B";
      if (bytes < 1048576) return Math.round(bytes / 1024) + " KB";
      return (bytes / 1048576).toFixed(1) + " MB";
    },

    fecha: function (iso) {
      if (!iso) return "—";
      var d = new Date(iso);
      if (isNaN(d)) return "—";
      return d.toLocaleDateString("es-PY", { day: "2-digit", month: "2-digit", year: "numeric" });
    },

    fechaHora: function (iso) {
      if (!iso) return "—";
      var d = new Date(iso);
      if (isNaN(d)) return "—";
      return d.toLocaleDateString("es-PY", { day: "2-digit", month: "2-digit", year: "numeric" }) +
             " " + d.toLocaleTimeString("es-PY", { hour: "2-digit", minute: "2-digit" });
    }
  };

  window.UI = UI;
})();
