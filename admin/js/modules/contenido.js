/* Tic's Solutions — páginas, servicios y soluciones */
(function () {
  "use strict";

  var el = UI.el;

  var ESTADOS = [
    { valor: "published", texto: "Publicado" },
    { valor: "draft",     texto: "Borrador" }
  ];

  /* ========================================================== páginas === */
  // Queda escrita pero SIN registrar, igual que Multimedia.
  //
  // Es la pantalla del título de pestaña y la descripción para Google. Sigue
  // funcionando: los títulos que ya están cargados se ven en el sitio, uno
  // por ruta. Lo que se saca es la posibilidad de cambiarlos desde el panel.
  //
  // Para volver a colgarla, pasarle este objeto a App.modulo.
  var MODULO_PAGINAS = {
    id: "paginas",
    titulo: "Páginas",
    sub: "Lo que se ve en la pestaña del navegador y en Google",
    grupo: "Contenido",
    icono: "▤",
    render: function (nodo) {
      return Crud({
        tabla: "pages",
        titulo: "página",
        femenino: true,
        plural: "páginas",
        sinCrear: true,
        sinBorrar: true,
        columnas: [
          { titulo: "Página", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.name }),
                el("div.celda-secundaria", { texto: f.route })
              ]); } },
          { titulo: "Título de la pestaña", celda: function (f) {
              return f.seo_title || el("span", { texto: "sin definir",
                estilo: "color:var(--gris-claro)" }); } },
          { titulo: "Descripción", celda: function (f) {
              return f.seo_description
                ? el("span", { texto: "cargada" })
                : el("span", { texto: "usa la general", estilo: "color:var(--gris-claro)" }); } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
        ],
        // Faltan a propósito los campos del menú y el orden. El menú del
        // sitio está escrito en la página y no sale de acá, así que cambiarlos
        // no movía nada y solo hacía creer que sí.
        campos: [
          { nombre: "name",     etiqueta: "Nombre",   requerido: true,
            ayuda: "Solo para encontrarla en esta lista." },
          { nombre: "route",    etiqueta: "Ruta", ayuda: "No cambiarla: rompería enlaces ya compartidos." },
          { nombre: "seo_title", etiqueta: "Título de la pestaña", ancho: "total",
            ayuda: "Lo que se lee en la pestaña del navegador y como titular en Google." },
          { nombre: "seo_description", etiqueta: "Descripción", tipo: "textarea", ancho: "total",
            ayuda: "El párrafo que Google muestra debajo del título. Hasta unos 160 caracteres. Vacío usa la descripción general del sitio." },
          { nombre: "status",   etiqueta: "Estado", tipo: "select", opciones: ESTADOS }
        ]
      }).render(nodo);
    }
  };
  void MODULO_PAGINAS;

  /* =================================================== textos por página === */
  // El titular y la entrada de cada sección del sitio. Se agrupan por página
  // porque así es como se los encuentra: "el texto de Ciberseguridad", no
  // "la fila ciberseguridad".
  //
  // No se crean ni se borran: cada fila corresponde a una sección que ya
  // existe en el sitio. Una fila de más no aparecería en ningún lado, y una
  // de menos deja al sitio mostrando su texto de fábrica.
  // Sin registrar, como el resto de las que se ocultaron. Los textos que ya
  // están cargados se siguen mostrando en el sitio: lo que se saca es la
  // pantalla para cambiarlos.
  //
  // Para volver a colgarla, pasarle este objeto a App.modulo.
  var MODULO_TEXTOS = {
    id: "textos",
    titulo: "Textos de las páginas",
    sub: "Titulares y entradas de cada sección",
    grupo: "Contenido",
    icono: "¶",

    async render(nodo) {
      var paginas, secciones;
      try {
        var p = await sb.from("pages").select("*").order("sort_order");
        if (p.error) throw p.error;
        var s = await sb.from("page_sections").select("*").order("sort_order");
        if (s.error) throw s.error;
        paginas = p.data; secciones = s.data;
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      UI.vaciar(nodo);

      if (!secciones.length) {
        nodo.appendChild(el("div.tarjeta", {}, [
          UI.vacio("Todavía no hay textos cargados", "Se cargan con el seed inicial del contenido.")
        ]));
        return;
      }

      nodo.appendChild(el("div.aviso", { texto:
        "Lo que se escribe acá reemplaza el texto del sitio. Si una sección se " +
        "apaga, el sitio vuelve a mostrar su texto original." }));

      paginas.forEach(function (pagina) {
        var propias = secciones.filter(function (s) { return s.page_id === pagina.id; });
        if (!propias.length) return;

        var tarjeta = el("div.tarjeta", { estilo: "margin-bottom:18px" }, [
          el("div.tarjeta-titulo", {}, [
            el("div", {}, [
              el("p.rotulo", { texto: pagina.route }),
              el("h2", { texto: pagina.name })
            ])
          ])
        ]);

        tarjeta.appendChild(UI.tabla([
          { titulo: "Titular", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.title || "(sin titular)" }),
                el("div.celda-secundaria", { texto: recortar(f.body, 80) })
              ]); } },
          { titulo: "Parte en rojo", celda: function (f) {
              return f.highlight_text ||
                el("span", { texto: "—", estilo: "color:var(--gris-claro)" }); } },
          { titulo: "Estado", celda: function (f) {
              return f.is_visible
                ? el("span.insignia.insignia-publicado", { texto: "En el sitio" })
                : el("span.insignia.insignia-archivado", { texto: "Texto original" }); } },
          { titulo: "", clase: "celda-acciones", celda: function (f) {
              return el("button.btn.btn-chico", {
                type: "button", texto: "Editar",
                onclick: function () { abrirSeccion(f, pagina); }
              }); } }
        ], propias));

        nodo.appendChild(tarjeta);
      });
    }
  };
  void MODULO_TEXTOS;

  function recortar(t, n) {
    if (!t) return "";
    return t.length > n ? t.slice(0, n) + "…" : t;
  }

  async function abrirSeccion(sec, pagina) {
    var campos = [
      { nombre: "eyebrow", etiqueta: "Rótulo superior", ancho: "total",
        ayuda: "El texto chico en rojo que va arriba del titular." },
      { nombre: "title", etiqueta: "Titular", ancho: "total", requerido: true },
      { nombre: "highlight_text", etiqueta: "Parte en rojo", ancho: "total",
        ayuda: "Tiene que ser un fragmento exacto del titular. Vacío deja el titular todo del mismo color." },
      { nombre: "body", etiqueta: "Entrada", tipo: "textarea", ancho: "total",
        ayuda: "El párrafo que va debajo del titular. No todas las secciones tienen uno." },
      { nombre: "is_visible", etiqueta: "Usar este texto en el sitio", tipo: "interruptor",
        ayuda: "Apagado, el sitio muestra el texto original con el que salió publicado." }
    ];

    var cuerpo = UI.formulario(campos, sec);

    var guardar = await UI.modal({
      titulo: pagina.name,
      ancho: true,
      cuerpo: cuerpo,
      botones: [
        { texto: "Cancelar", alPulsar: function (c) { c(null); } },
        { texto: "Guardar", clase: "btn-primario",
          alPulsar: function (cerrar, caja) { cerrar(UI.leerFormulario(caja, campos)); } }
      ]
    });

    if (!guardar) return;

    if (!guardar.title) {
      UI.error("El titular no puede quedar vacío. No se guardó.");
      return;
    }
    // Si el resalte no está dentro del titular, el sitio muestra la frase
    // entera sin pintar nada. Mejor avisar acá que dejar que se note en vivo.
    if (guardar.highlight_text && guardar.title.indexOf(guardar.highlight_text) < 0) {
      UI.error("La parte en rojo no aparece dentro del titular. No se guardó.");
      return;
    }

    try {
      var r = await sb.from("page_sections").update({
        eyebrow: guardar.eyebrow || null,
        title: guardar.title,
        highlight_text: guardar.highlight_text || null,
        body: guardar.body || null,
        is_visible: !!guardar.is_visible
      }).eq("id", sec.id);
      if (r.error) throw r.error;
      await Auth.anotar("update", "page_sections", sec.id, { seccion: sec.section_key });
      UI.ok("Texto actualizado.");
      App.ir();
    } catch (e) { UI.error(Auth.mensajeDeError(e)); }
  }

  /* ======================================================== servicios === */
  App.modulo({
    id: "servicios",
    titulo: "Servicios",
    sub: "Lo que ofrece Tic's Solutions",
    grupo: "Contenido",
    icono: "▣",
    render: function (nodo) {
      return Crud({
        tabla: "services",
        titulo: "servicio",
        plural: "servicios",
        columnas: [
          { titulo: "Servicio", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.title }),
                el("div.celda-secundaria", { texto: f.short_description || f.slug })
              ]); } },
          { titulo: "Destacado", celda: function (f) {
              return f.is_featured ? el("span.insignia.insignia-nuevo", { texto: "Destacado" }) : "—"; } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
        ],
        campos: [
          { nombre: "title", etiqueta: "Título", requerido: true, ancho: "total" },
          { nombre: "slug",  etiqueta: "Slug", ayuda: "Se genera solo si lo dejás vacío." },
          { nombre: "short_description", etiqueta: "Resumen", ancho: "total",
            ayuda: "Una línea. Es lo que se ve en la grilla." },
          { nombre: "description", etiqueta: "Descripción", tipo: "textarea", ancho: "total" },
          { nombre: "cta_label", etiqueta: "Texto del botón" },
          { nombre: "cta_url",   etiqueta: "Enlace del botón" },
          { nombre: "is_featured", etiqueta: "Destacado", tipo: "interruptor" },
          { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
          { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
        ],
        porDefecto: { status: "published", is_featured: false },
        alGuardar: function (datos) {
          if (!datos.slug) datos.slug = UI.slug(datos.title);
          return datos;
        }
      }).render(nodo);
    }
  });

  /* ======================================================= soluciones === */
  // Se muestran agrupadas por unidad, como en el sitio.
  App.modulo({
    id: "soluciones",
    titulo: "Soluciones",
    sub: "ZWCAD, ZW3D, Aplitop, CADprofi y Arcserve",
    grupo: "Contenido",
    icono: "◆",

    async render(nodo) {
      var unidades, soluciones;
      // Si se entró a las tarjetas de una solución, la pantalla muestra eso
      // en vez de la lista. Se guarda afuera para que App.ir() no lo pierda
      // al repintar después de guardar.
      var verTarjetas = sessionStorage.getItem("ticspy.soluciones.tarjetas");
      if (verTarjetas) return pintarTarjetas(nodo, verTarjetas);

      try {
        var u = await sb.from("solution_units").select("*").order("sort_order");
        if (u.error) throw u.error;
        var s = await sb.from("solutions").select("*").order("sort_order");
        if (s.error) throw s.error;
        unidades = u.data; soluciones = s.data;
        await Media.cargar();
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      UI.vaciar(nodo);

      if (!soluciones.length) {
        nodo.appendChild(el("div.tarjeta", {}, [
          UI.vacio("Todavía no hay soluciones", "Se cargan con el seed inicial del contenido.")
        ]));
        return;
      }

      unidades.forEach(function (unidad) {
        var propias = soluciones.filter(function (s) { return s.unit_id === unidad.id; });
        if (!propias.length) return;

        var tarjeta = el("div.tarjeta", { estilo: "margin-bottom:18px" }, [
          el("div.tarjeta-titulo", {}, [
            el("div", {}, [
              el("p.rotulo", { texto: "Unidad" }),
              el("h2", { texto: unidad.name })
            ])
          ])
        ]);

        tarjeta.appendChild(UI.tabla([
          { titulo: "Solución", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.name }),
                el("div.celda-secundaria", { texto: f.headline || "" })
              ]); } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } },
          { titulo: "", clase: "celda-acciones", celda: function (f) {
              return el("div", { estilo: "display:inline-flex;gap:6px" }, [
                el("button.btn.btn-chico", {
                  type: "button", texto: "Tarjetas e imágenes",
                  onclick: function () {
                    sessionStorage.setItem("ticspy.soluciones.tarjetas", f.id);
                    App.ir();
                  }
                }),
                el("button.btn.btn-chico", {
                  type: "button", texto: "Editar",
                  onclick: function () { abrirSolucion(f); }
                })
              ]); } }
        ], propias));

        nodo.appendChild(tarjeta);
      });
    }
  });

  /* ------------------------------------------- tarjetas de una solución -- */
  // Acá viven las imágenes que se ven en el sitio: las tarjetas de novedades
  // de ZWCAD, los módulos de ZW3D y los videos de CADprofi. Antes no había
  // forma de verlas desde el panel.
  //
  // Es una vista aparte y no una pestaña más de la ficha: son listas, no
  // campos, y meterlas en el mismo diálogo obligaría a abrir un diálogo
  // dentro de otro para editar cada fila.
  async function pintarTarjetas(nodo, solucionId) {
    var sol, tarjetas, videos;
    try {
      var s = await sb.from("solutions").select("*").eq("id", solucionId).maybeSingle();
      if (s.error) throw s.error;
      sol = s.data;
      var f = await sb.from("solution_features").select("*")
        .eq("solution_id", solucionId).order("sort_order");
      if (f.error) throw f.error;
      var d = await sb.from("solution_demos").select("*")
        .eq("solution_id", solucionId).order("sort_order");
      if (d.error) throw d.error;
      tarjetas = f.data; videos = d.data;
      await Media.cargar();
    } catch (e) {
      UI.vaciar(nodo);
      if (!App.franjaSiFalta(nodo, e)) {
        nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
      }
      return;
    }

    UI.vaciar(nodo);

    if (!sol) {
      sessionStorage.removeItem("ticspy.soluciones.tarjetas");
      App.ir();
      return;
    }

    nodo.appendChild(el("button.btn.btn-chico", {
      type: "button", texto: "← Volver a soluciones",
      estilo: "margin-bottom:16px",
      onclick: function () {
        sessionStorage.removeItem("ticspy.soluciones.tarjetas");
        App.ir();
      }
    }));

    if (!tarjetas.length && !videos.length) {
      nodo.appendChild(el("div.tarjeta", {}, [
        UI.vacio("Esta solución no tiene tarjetas",
          "Las tarjetas con imagen son las de ZWCAD, ZW3D y CADprofi.")
      ]));
      return;
    }

    // Las tarjetas vienen agrupadas por su clave de grupo, que es la misma
    // que separa las secciones en el sitio.
    var grupos = {};
    tarjetas.forEach(function (t) {
      var g = t.group_key || "otras";
      (grupos[g] = grupos[g] || []).push(t);
    });

    Object.keys(grupos).forEach(function (g) {
      nodo.appendChild(bloque(sol.name + " · " + (NOMBRE_GRUPO[g] || g), grupos[g], [
        { titulo: "", ancho: "62px", celda: function (f) { return Media.mini(f.media_id, f.title); } },
        { titulo: "Tarjeta", celda: function (f) {
            return el("div", {}, [
              el("div.celda-principal", { texto: f.title || "(sin título)" }),
              el("div.celda-secundaria", { texto: recortar(f.description, 70) })
            ]); } },
        { titulo: "Etiqueta", celda: function (f) {
            return f.label || el("span", { texto: "—", estilo: "color:var(--gris-claro)" }); } },
        { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } },
        { titulo: "", clase: "celda-acciones", celda: function (f) {
            return el("button.btn.btn-chico", {
              type: "button", texto: "Editar",
              onclick: function () { editarTarjeta(f); }
            }); } }
      ]));
    });

    if (videos.length) {
      nodo.appendChild(bloque(sol.name + " · Videos", videos, [
        { titulo: "", ancho: "62px", celda: function (f) { return Media.mini(f.video_media_id, f.title); } },
        { titulo: "Video", celda: function (f) {
            return el("div", {}, [
              el("div.celda-principal", { texto: f.title || "(sin título)" }),
              el("div.celda-secundaria", { texto: recortar(f.description, 70) })
            ]); } },
        { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } },
        { titulo: "", clase: "celda-acciones", celda: function (f) {
            return el("button.btn.btn-chico", {
              type: "button", texto: "Editar",
              onclick: function () { editarVideo(f); }
            }); } }
      ]));
    }

    function bloque(titulo, filas, columnas) {
      var t = el("div.tarjeta", { estilo: "margin-bottom:18px" }, [
        el("div.tarjeta-titulo", {}, [
          el("div", {}, [
            el("p.rotulo", { texto: filas.length + (filas.length === 1 ? " fila" : " filas") }),
            el("h2", { texto: titulo })
          ])
        ])
      ]);
      t.appendChild(UI.tabla(columnas, filas));
      return t;
    }
  }

  var NOMBRE_GRUPO = {
    novedades: "Novedades de la versión",
    especializado: "Módulos especializados"
  };

  async function editarTarjeta(f) {
    var campos = [
      { nombre: "media_id", etiqueta: "Imagen", tipo: "imagen", ancho: "total",
        ayuda: "Es la que se ve en la tarjeta del sitio." },
      { nombre: "title", etiqueta: "Título", requerido: true, ancho: "total" },
      { nombre: "label", etiqueta: "Etiqueta", ayuda: "El recuadro chico de color, si lleva." },
      { nombre: "description", etiqueta: "Texto", tipo: "textarea", ancho: "total" },
      { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
      { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
    ];
    await guardarFila("solution_features", f, campos, f.title);
  }

  async function editarVideo(f) {
    var campos = [
      { nombre: "video_media_id", etiqueta: "Video", tipo: "imagen", soloVideo: true, ancho: "total",
        ayuda: "Es el que se reproduce en el sitio." },
      { nombre: "title", etiqueta: "Título", requerido: true, ancho: "total" },
      { nombre: "description", etiqueta: "Texto", tipo: "textarea", ancho: "total" },
      { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
      { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
    ];
    await guardarFila("solution_demos", f, campos, f.title);
  }

  async function guardarFila(tabla, fila, campos, nombre) {
    var cuerpo = UI.formulario(campos, fila);
    var datos = await UI.modal({
      titulo: "Editar " + (nombre || "fila"),
      ancho: true,
      cuerpo: cuerpo,
      botones: [
        { texto: "Cancelar", alPulsar: function (c) { c(null); } },
        { texto: "Guardar", clase: "btn-primario",
          alPulsar: function (cerrar, caja) {
            var d = UI.leerFormulario(caja, campos);
            if (!d.title) { UI.error("El título no puede quedar vacío."); return; }
            cerrar(d);
          } }
      ]
    });
    if (!datos) return;

    try {
      var r = await sb.from(tabla).update(datos).eq("id", fila.id);
      if (r.error) throw r.error;
      await Auth.anotar("update", tabla, fila.id, { nombre: datos.title });
      UI.ok("Cambios guardados.");
      App.ir();
    } catch (e) { UI.error(Auth.mensajeDeError(e)); }
  }

  // Ficha de solución, con pestañas: son muchos campos para una sola lista.
  async function abrirSolucion(sol) {
    var campos = {
      general: [
        { nombre: "name", etiqueta: "Nombre", requerido: true },
        { nombre: "short_name", etiqueta: "Nombre corto" },
        { nombre: "version", etiqueta: "Versión" },
        { nombre: "category", etiqueta: "Categoría" },
        { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
        { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
      ],
      contenido: [
        { nombre: "eyebrow", etiqueta: "Rótulo superior", ancho: "total" },
        { nombre: "headline", etiqueta: "Titular", ancho: "total", requerido: true },
        { nombre: "headline_highlight", etiqueta: "Parte en rojo", ancho: "total",
          ayuda: "Tiene que ser un fragmento exacto del titular." },
        { nombre: "intro", etiqueta: "Entrada", tipo: "textarea", ancho: "total" },
        { nombre: "cta_label", etiqueta: "Texto del botón" },
        { nombre: "cta_url", etiqueta: "Enlace del botón" },
        { nombre: "legal_note", etiqueta: "Nota legal", tipo: "textarea", ancho: "total" }
      ]
    };

    var pestanaActiva = "general";
    var contenedor = el("div");
    var barra = el("div.pestanas");
    var cuerpo = el("div");

    function pintar() {
      UI.vaciar(barra);
      ["general", "contenido"].forEach(function (p) {
        barra.appendChild(el("button.pestana" + (p === pestanaActiva ? ".activa" : ""), {
          type: "button", texto: p === "general" ? "General" : "Contenido",
          onclick: function () { recordar(); pestanaActiva = p; pintar(); }
        }));
      });
      UI.vaciar(cuerpo);
      cuerpo.appendChild(UI.formulario(campos[pestanaActiva], sol));
    }

    // Al cambiar de pestaña el DOM se rehace: lo escrito se guarda en `sol`
    // para no perderlo.
    function recordar() {
      Object.assign(sol, UI.leerFormulario(cuerpo, campos[pestanaActiva]));
    }

    contenedor.appendChild(barra);
    contenedor.appendChild(cuerpo);
    pintar();

    var guardar = await UI.modal({
      titulo: "Editar " + sol.name,
      ancho: true,
      cuerpo: contenedor,
      botones: [
        { texto: "Cancelar", alPulsar: function (c) { c(false); } },
        { texto: "Guardar", clase: "btn-primario", alPulsar: function (c) { recordar(); c(true); } }
      ]
    });

    if (!guardar) return;

    // El resalte tiene que existir dentro del titular o el sitio no lo pinta.
    if (sol.headline_highlight && sol.headline &&
        sol.headline.indexOf(sol.headline_highlight) < 0) {
      UI.error("La parte en rojo no aparece dentro del titular. No se guardó.");
      return;
    }
    if (!UI.urlSegura(sol.cta_url)) {
      UI.error("Ese enlace no es válido.");
      return;
    }

    var datos = {};
    ["name","short_name","version","category","status","sort_order","eyebrow",
     "headline","headline_highlight","intro","cta_label","cta_url","legal_note"]
      .forEach(function (k) { datos[k] = sol[k]; });

    try {
      var r = await sb.from("solutions").update(datos).eq("id", sol.id);
      if (r.error) throw r.error;
      await Auth.anotar("update", "solutions", sol.id, { nombre: sol.name });
      UI.ok("Solución actualizada.");
      App.ir();
    } catch (e) { UI.error(Auth.mensajeDeError(e)); }
  }
})();
