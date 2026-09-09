/* Tic's Solutions — páginas, servicios y soluciones */
(function () {
  "use strict";

  var el = UI.el;

  var ESTADOS = [
    { valor: "published", texto: "Publicado" },
    { valor: "draft",     texto: "Borrador" }
  ];

  /* ========================================================== páginas === */
  // Las rutas no se crean ni se borran desde el panel: cada una tiene su
  // sección en el sitio. Cambiar una URL rompería enlaces ya compartidos.
  App.modulo({
    id: "paginas",
    titulo: "Páginas",
    sub: "Las 14 rutas del sitio, su nombre y su SEO",
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
          { titulo: "En el menú", celda: function (f) {
              return f.show_in_nav ? (f.nav_label || "Sí") : "—"; } },
          { titulo: "Título SEO", celda: function (f) {
              return f.seo_title || el("span", { texto: "sin definir",
                estilo: "color:var(--gris-claro)" }); } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
        ],
        campos: [
          { nombre: "name",     etiqueta: "Nombre",   requerido: true },
          { nombre: "nav_label", etiqueta: "Texto en el menú" },
          { nombre: "route",    etiqueta: "Ruta", ayuda: "No cambiarla: rompería enlaces ya compartidos." },
          { nombre: "seo_title", etiqueta: "Título SEO", ancho: "total",
            ayuda: "Lo que se ve en la pestaña del navegador y en Google." },
          { nombre: "seo_description", etiqueta: "Descripción SEO", tipo: "textarea", ancho: "total",
            ayuda: "Hasta unos 160 caracteres." },
          { nombre: "show_in_nav", etiqueta: "Mostrar en el menú", tipo: "interruptor" },
          { nombre: "status",   etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
          { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
        ]
      }).render(nodo);
    }
  });

  /* =================================================== textos por página === */
  // El titular y la entrada de cada sección del sitio. Se agrupan por página
  // porque así es como se los encuentra: "el texto de Ciberseguridad", no
  // "la fila ciberseguridad".
  //
  // No se crean ni se borran: cada fila corresponde a una sección que ya
  // existe en el sitio. Una fila de más no aparecería en ningún lado, y una
  // de menos deja al sitio mostrando su texto de fábrica.
  App.modulo({
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
  });

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
      try {
        var u = await sb.from("solution_units").select("*").order("sort_order");
        if (u.error) throw u.error;
        var s = await sb.from("solutions").select("*").order("sort_order");
        if (s.error) throw s.error;
        unidades = u.data; soluciones = s.data;
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
              return el("button.btn.btn-chico", {
                type: "button", texto: "Editar",
                onclick: function () { abrirSolucion(f); }
              }); } }
        ], propias));

        nodo.appendChild(tarjeta);
      });
    }
  });

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
      UI.ok("Solución actualizada.");
      App.ir();
    } catch (e) { UI.error(Auth.mensajeDeError(e)); }
  }
})();
