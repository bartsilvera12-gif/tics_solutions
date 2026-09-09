/* Tic's Solutions — imágenes compartidas entre pantallas
 *
 * Varias pantallas muestran la misma imagen: el logo de una marca, la foto de
 * una tarjeta, el video de una demo. Antes cada una se la arreglaba sola y
 * solo Partners y marcas llegaba a mostrarla.
 *
 * Acá se cargan una vez y quedan en memoria mientras dure la sesión. Son
 * menos de cien filas y se piden en cada pantalla que las necesita: pedirlas
 * de nuevo cada vez sería una consulta por pantalla sin ninguna ganancia.
 */
(function () {
  "use strict";

  var el = UI.el;
  var cache = null;

  var Media = {
    // Todas las piezas, por id. Se piden una sola vez.
    async cargar(refrescar) {
      if (cache && !refrescar) return cache;
      var r = await sb.from("media_assets")
        .select("id, public_url, original_name, mime_type, width, height, alt_text")
        .order("created_at", { ascending: false })
        .limit(500);
      if (r.error) throw r.error;
      cache = {};
      (r.data || []).forEach(function (m) { cache[m.id] = m; });
      return cache;
    },

    // Lo que hay cargado, sin ir a la red. Sirve para pintar una tabla.
    mapa() { return cache || {}; },

    esVideo(m) { return !!(m && /^video\//.test(m.mime_type || "")); },

    // Miniatura para una celda. Un video no se puede mostrar como imagen, así
    // que se marca con un símbolo en vez de dejar el cuadro vacío.
    mini(id, alt) {
      var m = (cache || {})[id];
      if (!m) return el("div.mini", { title: "sin imagen" });
      if (this.esVideo(m)) {
        return el("div.mini", {
          title: m.original_name || "video",
          estilo: "display:flex;align-items:center;justify-content:center;font-size:16px",
          texto: "▶"
        });
      }
      return el("img.mini", {
        src: m.public_url,
        alt: alt || m.alt_text || "",
        loading: "lazy"
      });
    },

    // Elige una pieza de la biblioteca.
    //
    // Devuelve null si se cancela y { id } si se aceptó, con id en null
    // cuando se quiso quitar la imagen. Van envueltos a propósito: el diálogo
    // también resuelve en null al tocar Escape o el fondo, y si "quitar" y
    // "cancelar" fueran los dos null, salir con Escape borraría la imagen.
    async elegir(actual, soloVideo) {
      var piezas;
      try {
        var todas = await this.cargar();
        piezas = Object.keys(todas).map(function (k) { return todas[k]; });
      } catch (e) {
        UI.error(Auth.mensajeDeError(e));
        return null;
      }

      if (soloVideo) piezas = piezas.filter(Media.esVideo.bind(Media));

      var elegida = actual || null;
      var rejilla = el("div", {
        estilo: "display:grid;grid-template-columns:repeat(auto-fill,minmax(104px,1fr));" +
                "gap:10px;max-height:52vh;overflow:auto;padding:2px"
      });

      var buscador = el("input", {
        type: "search", placeholder: "Buscar por nombre",
        estilo: "width:100%;margin-bottom:12px"
      });

      function pintar() {
        UI.vaciar(rejilla);
        var texto = buscador.value.trim().toLowerCase();
        var vistas = piezas.filter(function (m) {
          if (!texto) return true;
          return String(m.original_name || "").toLowerCase().indexOf(texto) >= 0;
        });

        if (!vistas.length) {
          rejilla.appendChild(el("p.campo-ayuda", { texto: "No hay archivos con ese nombre." }));
          return;
        }

        vistas.forEach(function (m) {
          var caja = el("button", {
            type: "button",
            title: m.original_name || "",
            estilo: "border:2px solid " + (m.id === elegida ? "var(--rojo)" : "var(--linea)") +
                    ";border-radius:var(--radio-chico);background:#fff;padding:6px;cursor:pointer;" +
                    "display:flex;flex-direction:column;gap:6px;align-items:center",
            onclick: function () { elegida = m.id; pintar(); }
          }, [
            Media.esVideo(m)
              ? el("div", { estilo: "height:64px;display:flex;align-items:center;font-size:22px", texto: "▶" })
              : el("img", { src: m.public_url, alt: "", loading: "lazy",
                            estilo: "width:100%;height:64px;object-fit:contain" }),
            el("span", {
              texto: (m.original_name || "").slice(-22),
              estilo: "font-size:10.5px;color:var(--gris);word-break:break-all;line-height:1.3"
            })
          ]);
          rejilla.appendChild(caja);
        });
      }

      buscador.addEventListener("input", pintar);
      pintar();

      var cuerpo = el("div", {}, [buscador, rejilla]);

      var r = await UI.modal({
        titulo: "Elegir " + (soloVideo ? "video" : "imagen"),
        ancho: true,
        cuerpo: cuerpo,
        botones: [
          { texto: "Cancelar", alPulsar: function (c) { c(null); } },
          { texto: "Quitar la imagen", alPulsar: function (c) { c({ id: null }); } },
          { texto: "Usar esta", clase: "btn-primario",
            alPulsar: function (c) {
              if (!elegida) { UI.error("Todavía no elegiste ninguna."); return; }
              c({ id: elegida });
            } }
        ]
      });

      return r;
    }
  };

  window.Media = Media;
})();
