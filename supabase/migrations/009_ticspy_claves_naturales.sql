-- =====================================================================
--  Tic's Solutions — 009: claves naturales en caracteristicas y demos
-- =====================================================================
--  Mismo problema que resolvio la 008 para media_assets, en las dos tablas
--  que quedaban: el seed insertaba con "on conflict do nothing" pero sin una
--  restriccion que lo respalde, esa clausula no compara con nada. Correr el
--  seed dos veces llevo las caracteristicas de 16 a 48 y los demos de 7 a 21.
--
--  La clave natural de cada una:
--    solution_features   una fila por solucion, grupo y clave de la ficha
--    solution_demos      una fila por solucion y slug del video
-- =====================================================================

-- 1. Deduplicar, conservando la mas vieja de cada grupo.
delete from ticspy.solution_features a
using ticspy.solution_features b
where a.solution_id = b.solution_id
  and a.group_key   is not distinct from b.group_key
  and a.feature_key is not distinct from b.feature_key
  and a.ctid > b.ctid;

delete from ticspy.solution_demos a
using ticspy.solution_demos b
where a.solution_id = b.solution_id
  and a.slug is not distinct from b.slug
  and a.ctid > b.ctid;

-- 2. Las restricciones que faltaban.
create unique index if not exists idx_features_clave
  on ticspy.solution_features (solution_id, group_key, feature_key);

create unique index if not exists idx_demos_clave
  on ticspy.solution_demos (solution_id, slug);
