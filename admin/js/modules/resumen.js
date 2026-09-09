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
          consultas:  await contar("contact_submissions", function (q) { return q.eq("status", "new"); }),
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
      App.contador("consultas", m.consultas);

      var tarjetas = [
        ["Servicios",  m.servicios,  "publicados",       "#/servicios"],
        ["Soluciones", m.soluciones, "activas",          "#/soluciones"],
        ["Textos",     m.textos,     "secciones del sitio", "#/textos"],
        ["Consultas",  m.consultas,  "sin leer",         "#/consultas"],
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

      // --- dos columnas: últimas consultas y últimos cambios ---
      var columnas = el("div", {
        estilo: "display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,320px),1fr));gap:16px"
      });

      // Últimas consultas
      var cajaConsultas = el("div.tarjeta", {}, [
        el("div.tarjeta-titulo", {}, [el("h2", { texto: "Últimas consultas" })])
      ]);
      try {
        var c = await sb.from("contact_submissions")
          .select("id,name,email,message,status,created_at")
          .order("created_at", { ascending: false }).limit(5);
        if (c.error) throw c.error;

        if (!c.data.length) {
          cajaConsultas.appendChild(UI.vacio("Sin consultas todavía",
            "Cuando alguien complete el formulario del sitio, va a aparecer acá."));
        } else {
          cajaConsultas.appendChild(UI.tabla([
            { titulo: "Quién", celda: function (f) {
                return el("div", {}, [
                  el("div.celda-principal", { texto: f.name }),
                  el("div.celda-secundaria", { texto: f.email })
                ]); } },
            { titulo: "Estado", celda: function (f) { return UI.insignia(f.status); } },
            { titulo: "Fecha", celda: function (f) { return UI.fecha(f.created_at); } }
          ], c.data));
        }
      } catch (e) {
        cajaConsultas.appendChild(el("div", { estilo: "padding:18px" }, [
          el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) })
        ]));
      }
      columnas.appendChild(cajaConsultas);

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
                  el("div.celda-principal", { texto: f.action }),
                  el("div.celda-secundaria", { texto: f.entity_table || "" })
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
