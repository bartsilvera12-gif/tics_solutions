/* Tic's Solutions — biblioteca multimedia
 *
 * Los 58 archivos que ya venían en el repositorio quedan registrados como
 * "local" y se siguen sirviendo desde el sitio. Lo que se sube desde acá va
 * a Supabase Storage: el almacenamiento de un hosting compartido no da
 * garantías de respaldo, y un archivo perdido no se recupera.
 */
(function () {
  "use strict";

  var el = UI.el;

  // Lo que el navegador puede mostrar y el sitio ya usa. Todo lo demás se
  // rechaza antes de subir: un .svg puede traer scripts adentro y un
  // ejecutable renombrado no tiene por qué llegar al bucket.
  var PERMITIDOS = {
    "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp",
    "image/gif": "gif", "video/mp4": "mp4", "video/webm": "webm"
  };
  var TOPE = 25 * 1024 * 1024;

  // Columnas que apuntan a media_assets. Sirve para avisar dónde se usa un
  // archivo antes de borrarlo.
  var USOS = [
    ["brands", "media_id", "marcas"],
    ["solution_features", "media_id", "características"],
    ["solution_demos", "video_media_id", "demos"],
    ["news_items", "media_id", "novedades"],
    ["services", "media_id", "servicios"],
    ["page_sections", "media_id", "secciones"],
    ["solutions", "logo_media_id", "logos de solución"]
  ];

  async function dondeSeUsa(id) {
    var lugares = [];
    for (var i = 0; i < USOS.length; i++) {
      var u = USOS[i];
      try {
        var r = await sb.from(u[0]).select("id", { count: "exact", head: true }).eq(u[1], id);
        if (!r.error && r.count) lugares.push(r.count + " en " + u[2]);
      } catch (e) { /* si una tabla falla, no se frena el resto */ }
    }
    return lugares;
  }

  // Queda escrita pero SIN registrar, igual que Novedades antes de
  // conectarse. Es la biblioteca de archivos: sirve para mirar y limpiar, no
  // para armar una página, y el sitio sigue leyendo media_assets como
  // siempre. Ocultarla no toca ninguna imagen.
  //
  // Para volver a colgarla, pasarle este objeto a App.modulo.
  var MODULO_MULTIMEDIA = {
    id: "multimedia",
    titulo: "Multimedia",
    sub: "Imágenes y videos del sitio",
    grupo: "Contenido",
    icono: "▨",

    async render(nodo) {
      var piezas;
      try {
        var r = await sb.from("media_assets").select("*")
          .order("created_at", { ascending: false }).limit(400);
        if (r.error) throw r.error;
        piezas = r.data;
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      UI.vaciar(nodo);

      // --- subir ---
      var entrada = el("input", {
        type: "file", hidden: true,
        accept: Object.keys(PERMITIDOS).join(","),
        onchange: function (ev) { subir(ev.target.files[0]); }
      });
      nodo.appendChild(entrada);

      App.accion(el("button.btn.btn-primario", {
        type: "button", texto: "+ Subir archivo",
        onclick: function () { entrada.click(); }
      }));

      if (!piezas.length) {
        nodo.appendChild(el("div.tarjeta", {}, [
          UI.vacio("La biblioteca está vacía",
            "Subí una imagen o un video para empezar.",
            el("button.btn.btn-primario", { type: "button", texto: "Subir archivo",
              onclick: function () { entrada.click(); } }))
        ]));
        return;
      }

      var galeria = el("div.galeria");
      piezas.forEach(function (p) {
        var esVideo = (p.mime_type || "").indexOf("video") === 0;
        var lienzo = el("div.pieza-lienzo", {}, [
          esVideo
            ? el("video", { src: p.public_url, muted: true, preload: "metadata" })
            : el("img", { src: p.public_url, alt: p.alt_text || "", loading: "lazy" })
        ]);

        galeria.appendChild(el("div.pieza", {
          onclick: function () { ficha(p); },
          title: p.original_name || ""
        }, [
          lienzo,
          el("div.pieza-datos", {}, [
            el("div.nombre", { texto: p.original_name || p.path || "sin nombre" }),
            el("div.detalle", {
              texto: [UI.peso(p.size_bytes),
                      p.width ? p.width + "×" + p.height : null,
                      p.storage_provider].filter(Boolean).join(" · ")
            })
          ])
        ]));
      });
      nodo.appendChild(galeria);

      /* ------------------------------------------------------- ficha -- */
      async function ficha(p) {
        var esVideo = (p.mime_type || "").indexOf("video") === 0;
        var campos = [{ nombre: "alt_text", etiqueta: "Texto alternativo", ancho: "total",
                        ayuda: "Describe la imagen para quien no puede verla y para los buscadores." }];

        var cuerpo = el("div", {}, [
          el("div.pieza-lienzo", { estilo: "max-height:290px;border-radius:8px;margin-bottom:18px" }, [
            esVideo
              ? el("video", { src: p.public_url, controls: true })
              : el("img", { src: p.public_url, alt: p.alt_text || "" })
          ]),
          UI.formulario(campos, p),
          el("p.campo-ayuda", {
            texto: [p.mime_type, UI.peso(p.size_bytes),
                    p.width ? p.width + "×" + p.height + " px" : null,
                    "origen: " + p.storage_provider].filter(Boolean).join("  ·  ")
          })
        ]);

        var accion = await UI.modal({
          titulo: p.original_name || "Archivo",
          cuerpo: cuerpo,
          botones: [
            { texto: "Eliminar", clase: "btn-peligro", alPulsar: function (c) { c("borrar"); } },
            { texto: "Cancelar", alPulsar: function (c) { c(null); } },
            { texto: "Guardar", clase: "btn-primario", alPulsar: function (c, caja) {
                c({ guardar: UI.leerFormulario(caja, campos) }); } }
          ]
        });

        if (!accion) return;

        if (accion === "borrar") {
          var usos = await dondeSeUsa(p.id);
          var texto = usos.length
            ? "Este archivo se está usando en " + usos.join(", ") +
              ". Si lo eliminás, esos lugares quedan sin imagen."
            : "No lo está usando ninguna sección. Esta acción no se puede deshacer.";
          var seguro = await UI.confirmar("Eliminar archivo", texto, "Sí, eliminar");
          if (!seguro) return;

          try {
            // Primero el archivo, después el registro: si se borra el
            // registro y falla el archivo, queda basura invisible en el bucket.
            if (p.storage_provider === "supabase" && p.path) {
              await sbStorage.remove([p.path]);
            }
            var r = await sb.from("media_assets").delete().eq("id", p.id);
            if (r.error) throw r.error;
            UI.ok("Archivo eliminado.");
            App.ir();
          } catch (e) { UI.error(Auth.mensajeDeError(e)); }
          return;
        }

        try {
          var up = await sb.from("media_assets")
            .update({ alt_text: accion.guardar.alt_text }).eq("id", p.id);
          if (up.error) throw up.error;
          UI.ok("Guardado.");
          App.ir();
        } catch (e) { UI.error(Auth.mensajeDeError(e)); }
      }

      /* ------------------------------------------------------- subir -- */
      async function subir(archivo) {
        if (!archivo) return;

        if (!PERMITIDOS[archivo.type]) {
          UI.error("Ese tipo de archivo no está permitido. Se aceptan JPG, PNG, WEBP, GIF, MP4 y WEBM.");
          return;
        }
        if (archivo.size > TOPE) {
          UI.error("El archivo pesa " + UI.peso(archivo.size) + " y el tope son 25 MB.");
          return;
        }

        // Nombre propio: el original puede traer acentos, espacios o
        // repetirse, y en una URL eso da problemas.
        var ext = PERMITIDOS[archivo.type];
        var base = UI.slug(archivo.name.replace(/\.[^.]+$/, "")) || "archivo";
        var ruta = base + "-" + Date.now().toString(36) + "." + ext;

        UI.aviso("Subiendo " + archivo.name + "…");

        try {
          var s = await sbStorage.upload(ruta, archivo, {
            cacheControl: "3600", contentType: archivo.type, upsert: false
          });
          if (s.error) throw s.error;

          var publica = sbStorage.getPublicUrl(ruta);
          var url = publica && publica.data ? publica.data.publicUrl : null;

          // Las medidas se leen en el navegador: sirven para el diseño y
          // para no recortar mal una imagen después.
          var medidas = await medir(archivo).catch(function () { return {}; });

          var r = await sb.from("media_assets").insert({
            storage_provider: "supabase",
            bucket: window.TICS_CONFIG.BUCKET,
            path: ruta,
            public_url: url,
            original_name: archivo.name,
            mime_type: archivo.type,
            size_bytes: archivo.size,
            width: medidas.w || null,
            height: medidas.h || null
          });
          if (r.error) throw r.error;

          UI.ok("Archivo subido.");
          App.ir();
        } catch (e) {
          UI.error(Auth.mensajeDeError(e));
        }
      }

      function medir(archivo) {
        return new Promise(function (res, rej) {
          var url = URL.createObjectURL(archivo);
          var esVideo = archivo.type.indexOf("video") === 0;
          var n = esVideo ? document.createElement("video") : new Image();
          n.onloadedmetadata = n.onload = function () {
            res({ w: n.videoWidth || n.naturalWidth, h: n.videoHeight || n.naturalHeight });
            URL.revokeObjectURL(url);
          };
          n.onerror = function () { URL.revokeObjectURL(url); rej(); };
          n.src = url;
        });
      }
    }
  };
  void MODULO_MULTIMEDIA;
})();
