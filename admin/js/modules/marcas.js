/* Tic's Solutions — marcas, partners y novedades */
(function () {
  "use strict";

  var el = UI.el;

  var ESTADOS = [
    { valor: "published", texto: "Publicado" },
    { valor: "draft",     texto: "Borrador" }
  ];


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
      try {
        await Media.cargar();
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
          femenino: tipo !== "partner",
          plural: tipo === "partner" ? "partners" : "marcas",
          filtroFijo: function (f) { return f.brand_type === tipo; },
          columnas: [
            { titulo: "", ancho: "62px", celda: function (f) { return Media.mini(f.media_id, f.name); } },
            { titulo: "Marca", celda: function (f) {
                return el("div", {}, [
                  el("div.celda-principal", { texto: f.name }),
                  el("div.celda-secundaria", { texto: f.route || f.website_url || "" })
                ]); } },
            { titulo: "Alto", celda: function (f) { return f.display_height || "—"; } },
            { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
          ],
          campos: [
            { nombre: "media_id", etiqueta: "Logo", tipo: "imagen", ancho: "total",
              ayuda: "Es lo que se ve en la cinta del sitio." },
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

      pintarPestanas();
      nodo.appendChild(barra);
      nodo.appendChild(cuerpo);
      listar();
    }
  });

  /* ======================================================== novedades === */
  // Lo que se carga acá sale en /novedades, en orden de fecha, de la más
  // nueva a la más vieja. Una novedad sin fecha no aparece: la tarjeta la
  // muestra arriba de todo y quedaría con un hueco.
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
        femenino: true,
        plural: "novedades",
        // El sitio las muestra por fecha, de la más nueva a la más vieja. La
        // lista de acá sigue el mismo orden y no lleva flechas para moverlas:
        // reordenar a mano no cambiaría nada en la web.
        orden: "published_at",
        descendente: true,
        sinOrden: true,
        columnas: [
          { titulo: "Novedad", celda: function (f) {
              return el("div", {}, [
                el("div.celda-principal", { texto: f.title }),
                el("div.celda-secundaria", { texto: f.summary || "" })
              ]); } },
          { titulo: "Etiqueta", celda: function (f) {
              return f.label ? el("span.insignia.insignia-nuevo", { texto: f.label }) : "—"; } },
          { titulo: "Fecha", celda: function (f) {
              return f.published_at ? UI.fecha(f.published_at)
                : el("span", { texto: "sin fecha", estilo: "color:var(--rojo)" }); } },
          { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } }
        ],
        campos: [
          { nombre: "title", etiqueta: "Título", requerido: true, ancho: "total" },
          { nombre: "label", etiqueta: "Etiqueta", marcador: "Evento",
            ayuda: "El recuadro chico en rojo. Las que ya usa el sitio son «Evento» y «Alianza»." },
          { nombre: "published_at", etiqueta: "Fecha", tipo: "date", requerido: true,
            ayuda: "Ordena la lista del sitio. Sin fecha, la novedad no se muestra." },
          { nombre: "summary", etiqueta: "Resumen", tipo: "textarea", ancho: "total",
            ayuda: "El párrafo que se lee en la tarjeta." },
          { nombre: "link_url", etiqueta: "Enlace", ancho: "total",
            marcador: "https://www.linkedin.com/posts/...",
            ayuda: "Normalmente la publicación en LinkedIn. Se abre en otra pestaña." },
          { nombre: "link_label", etiqueta: "Texto del enlace", marcador: "Ver la publicación en LinkedIn" },
          { nombre: "secondary_link_url", etiqueta: "Segundo enlace", marcador: "#/zwcad",
            ayuda: "Para mandar a una página del propio sitio." },
          { nombre: "secondary_link_label", etiqueta: "Texto del segundo enlace", marcador: "Conocer ZWCAD" },
          { nombre: "status", etiqueta: "Estado", tipo: "select", opciones: [
              { valor: "published", texto: "Publicada" },
              { valor: "draft",     texto: "Borrador" },
              { valor: "archived",  texto: "Archivada" }
            ] }
        ],
        porDefecto: { status: "draft" },
        alGuardar: function (datos, fila) {
          // El slug no se muestra en ningún lado: no hay una página por
          // novedad. Pero la columna es obligatoria y única, así que se arma
          // sola al crear y no se vuelve a tocar: si se regenerara en cada
          // edición, cambiar un título podría chocar con el slug de otra.
          if (!fila) datos.slug = UI.slug(datos.title);
          return datos;
        }
      }).render(nodo);
    }
  });
})();
