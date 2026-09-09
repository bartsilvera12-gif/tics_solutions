/* Tic's Solutions — resumen del panel
 *
 * Números reales, no adornos. Cada métrica es una consulta de conteo y cada
 * lista es lo último que pasó de verdad. Sin gráficos decorativos.
 */
(function () {
  "use strict";

  var el = UI.el;

  async function contar(tabla, filtro) {
    var q = sb.from(tabla).select("id", { count: "exact", head: true });
    if (filtro) q = filtro(q);
    var r = await q;
    if (r.error) throw r.error;
    return r.count || 0;
  }

  App.modulo({
    id: "resumen",
    titulo: "Resumen",
    sub: "Estado del contenido del sitio",
    grupo: "General",
    icono: "◈",

    async render(nodo) {
      var m;
      try {
        m = {
          servicios:  await contar("services",   function (q) { return q.eq("status", "published"); }),
          soluciones: await contar("solutions",  function (q) { return q.eq("status", "published"); }),
          textos:     await contar("page_sections", function (q) { return q.eq("is_visible", true); }),
          novedades:  await contar("news_items", function (q) { return q.eq("status", "published"); }),
          marcas:     await contar("brands",     function (q) { return q.eq("status", "published"); })
        };
      } catch (e) {
        UI.vaciar(nodo);
        if (!App.franjaSiFalta(nodo, e)) {
          nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
        }
        return;
      }

      UI.vaciar(nodo);
      var tarjetas = [
        ["Servicios",  m.servicios,  "publicados",       "#/servicios"],
        ["Soluciones", m.soluciones, "activas",          "#/soluciones"],
        ["Textos",     m.textos,     "secciones del sitio", "#/textos"],
        ["Marcas",     m.marcas,     "en las cintas",    "#/marcas"],
        ["Novedades",  m.novedades,  "publicadas",       "#/novedades"]
      ];

      var rejilla = el("div.metricas");
      tarjetas.forEach(function (t) {
        rejilla.appendChild(el("a.metrica", { href: t[3], estilo: "text-decoration:none;color:inherit;display:block" }, [
          el("p.rotulo", { texto: t[0] }),
          el("div.valor", { texto: String(t[1]) }),
          el("div.pie", { texto: t[2] })
        ]));
      });
      nodo.appendChild(rejilla);

      // Las últimas consultas ya no se listan acá: la pantalla que las
      // mostraba está oculta y no tiene sentido dejar un resumen de algo a lo
      // que no se puede entrar. Siguen llegando por correo.
      var columnas = el("div", {
        estilo: "display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,320px),1fr));gap:16px"
      });

      // Últimos cambios (auditoría)
      var cajaCambios = el("div.tarjeta", {}, [
        el("div.tarjeta-titulo", {}, [el("h2", { texto: "Últimas modificaciones" })])
      ]);
      try {
        var a = await sb.from("audit_logs")
          .select("id,action,entity_table,created_at")
          .order("created_at", { ascending: false }).limit(5);
        if (a.error) throw a.error;

        if (!a.data.length) {
          cajaCambios.appendChild(UI.vacio("Sin movimientos",
            "Acá queda registrado lo que se cree, edite o elimine desde el panel."));
        } else {
          cajaCambios.appendChild(UI.tabla([
            { titulo: "Acción", celda: function (f) {
                return el("div", {}, [
                  el("div.celda-principal", { texto: UI.ACCIONES[f.action] || f.action }),
                  el("div.celda-secundaria", { texto: UI.DONDE[f.entity_table] || f.entity_table || "" })
                ]); } },
            { titulo: "Cuándo", celda: function (f) { return UI.fechaHora(f.created_at); } }
          ], a.data));
        }
      } catch (e) {
        cajaCambios.appendChild(el("div", { estilo: "padding:18px" }, [
          el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) })
        ]));
      }
      columnas.appendChild(cajaCambios);

      nodo.appendChild(columnas);
    }
  });
})();
