/* Tic's Solutions — CRUD genérico
 *
 * Casi todas las secciones del panel son la misma pantalla: listar, crear,
 * editar, publicar u ocultar, reordenar y eliminar. En vez de repetir eso
 * diez veces, cada sección declara su tabla, sus columnas y sus campos, y
 * acá se arma sola. Lo específico de cada una se agrega por encima.
 *
 * Ordenar va con botones y no arrastrando: en el celular arrastrar filas es
 * incómodo y se dispara sin querer al hacer scroll.
 */
(function () {
  "use strict";

  var el = UI.el;

  window.Crud = function (spec) {
    /* spec:
     *   tabla      nombre en ticspy
     *   titulo     singular, para los diálogos
     *   orden      columna de ordenamiento por defecto
     *   columnas   [{titulo, celda(fila), clase, ancho}]
     *   campos     [{nombre, etiqueta, tipo, ...}] para el formulario
     *   alGuardar  (datos, fila) -> datos   opcional, para ajustar antes de escribir
     *   filtro     (fila, texto) -> bool    opcional, para el buscador
     *   sinCrear   true si la tabla no admite altas nuevas
     */
    var estado = { filas: [], base: [], busqueda: "" };

    function orden() { return spec.orden || "sort_order"; }

    async function traer() {
      var q = sb.from(spec.tabla).select("*");
      var r = await q.order(orden(), { ascending: true });
      if (r.error) throw r.error;
      return r.data || [];
    }

    /* ------------------------------------------------------- guardar -- */
    async function abrirFicha(fila) {
      var esNuevo = !fila;
      var cuerpo = UI.formulario(spec.campos, fila || spec.porDefecto || {});

      var valor = await UI.modal({
        titulo: (esNuevo ? "Nuevo" : "Editar") + " " + spec.titulo,
        ancho: spec.campos.length > 6,
        cuerpo: cuerpo,
        botones: [
          { texto: "Cancelar", alPulsar: function (c) { c(null); } },
          { texto: "Guardar", clase: "btn-primario",
            alPulsar: async function (cerrar, caja) {
              var datos = UI.leerFormulario(caja, spec.campos);

              // Validación mínima antes de tocar la base.
              var faltan = spec.campos.filter(function (c) {
                return c.requerido && !datos[c.nombre];
              });
              if (faltan.length) {
                UI.error("Falta completar: " + faltan.map(function (c) { return c.etiqueta; }).join(", "));
                return;
              }
              var malas = spec.campos.filter(function (c) {
                return /url/i.test(c.nombre) && !UI.urlSegura(datos[c.nombre]);
              });
              if (malas.length) {
                UI.error("Ese enlace no es válido: no se permiten javascript:, data: ni vbscript:.");
                return;
              }

              if (spec.alGuardar) datos = spec.alGuardar(datos, fila) || datos;
              cerrar(datos);
            } }
        ]
      });

      if (!valor) return;

      try {
        var r;
        if (esNuevo) {
          if (valor.sort_order == null) {
            valor.sort_order = estado.filas.reduce(function (m, f) {
              return Math.max(m, f.sort_order || 0);
            }, 0) + 1;
          }
          r = await sb.from(spec.tabla).insert(valor);
        } else {
          r = await sb.from(spec.tabla).update(valor).eq("id", fila.id);
        }
        if (r.error) throw r.error;
        UI.ok(esNuevo ? spec.titulo + " creado." : "Cambios guardados.");
        App.ir();
      } catch (e) {
        UI.error(Auth.mensajeDeError(e));
      }
    }

    /* -------------------------------------------------------- borrar -- */
    async function borrar(fila) {
      var nombre = fila.name || fila.title || fila.slug || "este registro";
      var seguro = await UI.confirmar(
        "Eliminar " + spec.titulo,
        "Se va a eliminar «" + nombre + "». Esta acción no se puede deshacer.",
        "Sí, eliminar");
      if (!seguro) return;

      try {
        var r = await sb.from(spec.tabla).delete().eq("id", fila.id);
        if (r.error) throw r.error;
        UI.ok("Eliminado.");
        App.ir();
      } catch (e) {
        UI.error(Auth.mensajeDeError(e));
      }
    }

    /* --------------------------------------------------- publicar --- */
    async function alternarEstado(fila) {
      var nuevo = fila.status === "published" ? "draft" : "published";
      try {
        var r = await sb.from(spec.tabla).update({ status: nuevo }).eq("id", fila.id);
        if (r.error) throw r.error;
        UI.ok(nuevo === "published" ? "Publicado." : "Oculto.");
        App.ir();
      } catch (e) { UI.error(Auth.mensajeDeError(e)); }
    }

    /* --------------------------------------------------- reordenar --- */
    async function mover(fila, delta) {
      // Sobre la lista visible, no sobre todas: en una pantalla con pestañas,
      // mover contra estado.filas intercambiaria un partner con una marca.
      var lista = estado.base.slice();
      var i = lista.findIndex(function (f) { return f.id === fila.id; });
      var j = i + delta;
      if (i < 0 || j < 0 || j >= lista.length) return;

      // Se intercambian las posiciones y se escriben las dos filas.
      var a = lista[i], b = lista[j];
      var oa = a.sort_order == null ? i : a.sort_order;
      var ob = b.sort_order == null ? j : b.sort_order;
      if (oa === ob) { ob = oa + delta; }

      try {
        var r1 = await sb.from(spec.tabla).update({ sort_order: ob }).eq("id", a.id);
        if (r1.error) throw r1.error;
        var r2 = await sb.from(spec.tabla).update({ sort_order: oa }).eq("id", b.id);
        if (r2.error) throw r2.error;
        App.ir();
      } catch (e) { UI.error(Auth.mensajeDeError(e)); }
    }

    /* --------------------------------------------------------- pintar -- */
    function pintar(nodo) {
      UI.vaciar(nodo);

      // El filtro fijo se aplica siempre: es el que separa, por ejemplo, los
      // partners de las marcas. El buscador se suma encima. Si se los mezcla
      // en uno solo, la pestaña no filtra hasta que alguien escribe algo.
      var base = spec.filtroFijo
        ? estado.filas.filter(function (f) { return spec.filtroFijo(f); })
        : estado.filas;

      // Reordenar trabaja sobre esta lista y no sobre todas las filas: en una
      // pantalla con pestañas, mover contra el total intercambiaría un
      // partner con una marca.
      estado.base = base;

      var visibles = base.filter(function (f) {
        if (!estado.busqueda) return true;
        var t = (f.name || "") + " " + (f.title || "") + " " + (f.slug || "");
        return t.toLowerCase().indexOf(estado.busqueda.toLowerCase()) >= 0;
      });

      if (!base.length) {
        nodo.appendChild(el("div.tarjeta", {}, [
          UI.vacio("Todavía no hay " + spec.plural,
            "Cuando cargues el primero va a aparecer acá.",
            spec.sinCrear ? null : el("button.btn.btn-primario", {
              type: "button", texto: "Crear " + spec.titulo,
              onclick: function () { abrirFicha(null); }
            }))
        ]));
        return;
      }

      var columnas = [];
      if (!spec.sinOrden) {
        columnas.push({
          titulo: "", ancho: "62px",
          celda: function (f) {
            return el("div", { estilo: "display:flex;gap:2px" }, [
              el("button.btn.btn-fantasma.btn-chico", {
                type: "button", texto: "↑", "aria-label": "Subir",
                onclick: function () { mover(f, -1); }
              }),
              el("button.btn.btn-fantasma.btn-chico", {
                type: "button", texto: "↓", "aria-label": "Bajar",
                onclick: function () { mover(f, 1); }
              })
            ]);
          }
        });
      }

      columnas = columnas.concat(spec.columnas);

      columnas.push({
        titulo: "", clase: "celda-acciones", ancho: "1%",
        celda: function (f) {
          var caja = el("div", { estilo: "display:inline-flex;gap:6px" });
          if (!spec.sinEstado) {
            caja.appendChild(el("button.btn.btn-fantasma.btn-chico", {
              type: "button",
              texto: f.status === "published" ? "Ocultar" : "Publicar",
              onclick: function () { alternarEstado(f); }
            }));
          }
          caja.appendChild(el("button.btn.btn-chico", {
            type: "button", texto: "Editar",
            onclick: function () { abrirFicha(f); }
          }));
          if (!spec.sinBorrar) {
            caja.appendChild(el("button.btn.btn-peligro.btn-chico", {
              type: "button", texto: "Eliminar",
              onclick: function () { borrar(f); }
            }));
          }
          return caja;
        }
      });

      var tarjeta = el("div.tarjeta");
      if (!visibles.length) {
        tarjeta.appendChild(UI.vacio("Sin resultados",
          "No hay " + spec.plural + " que coincidan con «" + estado.busqueda + "»."));
      } else {
        tarjeta.appendChild(UI.tabla(columnas, visibles));
      }
      nodo.appendChild(tarjeta);
    }

    /* --------------------------------------------------------- render -- */
    return {
      recargar: function () { App.ir(); },
      abrirFicha: abrirFicha,

      async render(nodo) {
        var filas;
        try {
          filas = await traer();
        } catch (e) {
          UI.vaciar(nodo);
          if (!App.franjaSiFalta(nodo, e)) {
            nodo.appendChild(el("div.aviso.aviso-error", { texto: Auth.mensajeDeError(e) }));
          }
          return;
        }

        estado.filas = filas;
        UI.vaciar(nodo);

        // Buscador y botón de alta, en la barra de arriba. El buscador
        // aparece según cuántas filas se ven en esta pestaña, no según el
        // total de la tabla.
        var cuantas = spec.filtroFijo
          ? filas.filter(function (f) { return spec.filtroFijo(f); }).length
          : filas.length;

        if (!spec.sinBuscar && cuantas > 6) {
          var buscador = el("input.control", {
            type: "search", placeholder: "Buscar…",
            estilo: "height:38px;width:210px",
            oninput: function (ev) {
              estado.busqueda = ev.target.value;
              pintar(document.getElementById("cuerpoLista"));
            }
          });
          App.accion(buscador);
        }

        if (!spec.sinCrear) {
          App.accion(el("button.btn.btn-primario", {
            type: "button", texto: "+ Nuevo " + spec.titulo,
            onclick: function () { abrirFicha(null); }
          }));
        }

        var cuerpo = el("div#cuerpoLista");
        nodo.appendChild(cuerpo);
        pintar(cuerpo);
      }
    };
  };
})();
