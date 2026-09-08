/* Tic's Solutions — marcas, partners y novedades */
(function () {
  "use strict";

  var el = UI.el;

  var ESTADOS = [
    { valor: "published", texto: "Publicado" },
    { valor: "draft",     texto: "Borrador" }
  ];

  function logo(f, media) {
    var m = media[f.media_id];
    if (!m) return el("div.mini", { title: "sin logo" });
    return el("img.mini", { src: m.public_url, alt: "", loading: "lazy" });
  }

  /* ================================================ marcas y partners === */
  // Dos cintas distintas del sitio: los partners son las marcas que se
  // licencian y las otras son el resto. Se editan igual, así que van en la
  // misma pantalla separadas por pestañas.
  App.modulo({
    id: "marcas",
    titulo: "Partners y marcas",
    sub: "Los logos de las dos cintas del sitio",
    grupo: "Contenido",
    icono: "◇",

    async render(nodo) {
      var media = {};
      try {
        var m = await sb.from("media_assets").select("id,public_url").limit(500);
        if (m.error) throw m.error;
        m.data.forEach(function (x) { media[x.id] = x; });
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      var tipo = (sessionStorage.getItem("ticspy.marcas.tipo") || "partner");

      UI.vaciar(nodo);
      var barra = el("div.pestanas");
      var cuerpo = el("div");

      function pintarPestanas() {
        UI.vaciar(barra);
        [["partner", "Partners"], ["brand", "Marcas"]].forEach(function (p) {
          barra.appendChild(el("button.pestana" + (p[0] === tipo ? ".activa" : ""), {
            type: "button", texto: p[1],
            onclick: function () {
              tipo = p[0];
              sessionStorage.setItem("ticspy.marcas.tipo", tipo);
              pintarPestanas();
              listar();
            }
          }));
        });
      }

      function listar() {
        UI.vaciar(cuerpo);
        Crud({
          tabla: "brands",
          titulo: tipo === "partner" ? "partner" : "marca",
          plural: tipo === "partner" ? "partners" : "marcas",
          filtro: function (f, t) {
            return f.brand_type === tipo &&
                   (f.name || "").toLowerCase().indexOf(t.toLowerCase()) >= 0;
          },
          columnas: [
            { titulo: "", ancho: "62px", celda: function (f) { return logo(f, media); } },
            { titulo: "Marca", celda: function (f) {
                return el("div", {}, [
                  el("div.celda-principal", { texto: f.name }),
                  el("div.celda-secundaria", { texto: f.route || f.website_url || "" })
                ]); } },
            { titulo: "Alto", celda: function (f) { return f.display_height || "—"; } },
            { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
          ],
          campos: [
            { nombre: "name", etiqueta: "Nombre", requerido: true },
            { nombre: "slug", etiqueta: "Slug" },
            { nombre: "route", etiqueta: "Ruta interna", marcador: "/zwcad" },
            { nombre: "website_url", etiqueta: "Sitio de la marca" },
            { nombre: "display_height", etiqueta: "Alto en la cinta", marcador: "34px",
              ayuda: "Cada logo tiene otra proporción: esto los empareja a la vista." },
            { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: ESTADOS },
            { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
          ],
          porDefecto: { status: "published", brand_type: tipo },
          alGuardar: function (datos) {
            if (!datos.slug) datos.slug = tipo + "-" + UI.slug(datos.name);
            datos.brand_type = tipo;
            return datos;
          }
        }).render(cuerpo);
      }

      // El buscador del CRUD filtra por tipo además del texto; para que la
      // pestaña funcione sin escribir nada, se arranca con el tipo puesto.
      pintarPestanas();
      nodo.appendChild(barra);
      nodo.appendChild(cuerpo);
      listar();
    }
  });

  /* ======================================================== novedades === */
  App.modulo({
    id: "novedades",
    titulo: "Novedades",
    sub: "Publicaciones y anuncios del sitio",
    grupo: "Contenido",
    icono: "✦",
    render: function (nodo) {
      return Crud({
        tabla: "news_items",
        titulo: "novedad",
        plural: "novedades",
        orden: "sort_order",
        columnas: [
          { titulo: "Novedad", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.title }),
                el("div.celda-secundaria", { texto: f.summary || "" })
              ]); } },
          { titulo: "Etiqueta", celda: function (f) {
              return f.label ? el("span.insignia.insignia-nuevo", { texto: f.label }) : "—"; } },
          { titulo: "Fecha", celda: function (f) { return UI.fecha(f.published_at); } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
        ],
        campos: [
          { nombre: "title", etiqueta: "Título", requerido: true, ancho: "total" },
          { nombre: "slug", etiqueta: "Slug" },
          { nombre: "label", etiqueta: "Etiqueta", marcador: "Nuevo",
            ayuda: "Las que ya usa el sitio son «Nuevo» y «Mejorado»." },
          { nombre: "summary", etiqueta: "Resumen", tipo: "textarea", ancho: "total" },
          { nombre: "body", etiqueta: "Contenido", tipo: "textarea", filas: 7, ancho: "total" },
          { nombre: "published_at", etiqueta: "Fecha de publicación", tipo: "date" },
          { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: [
              { valor: "published", texto: "Publicada" },
              { valor: "draft",     texto: "Borrador" },
              { valor: "archived",  texto: "Archivada" }
            ] },
          { nombre: "sort_order", etiqueta: "Orden", tipo: "number" }
        ],
        porDefecto: { status: "draft" },
        alGuardar: function (datos) {
          if (!datos.slug) datos.slug = UI.slug(datos.title);
          // Publicar sin fecha deja la novedad sin ordenar por tiempo.
          if (datos.status === "published" && !datos.published_at) {
            datos.published_at = new Date().toISOString();
          }
          return datos;
        }
      }).render(nodo);
    }
  });
})();
