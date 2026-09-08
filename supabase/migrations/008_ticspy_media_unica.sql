-- =====================================================================
--  Tic's Solutions — 008: una fila por archivo en media_assets
-- =====================================================================
--  El seed insertaba los 58 archivos con "on conflict do nothing", pero sin
--  un indice unico sobre path esa clausula no tiene con que comparar y no
--  evita nada: cada corrida agregaba 58 filas nuevas.
--
--  Se notaba recien mas adelante, cuando las marcas resuelven su logo con
--  (select id from media_assets where path = ...): con la ruta repetida, la
--  subconsulta devuelve dos filas y Postgres corta con 21000.
--
--  Aca se deduplica y se pone el indice que faltaba.
-- =====================================================================

-- 1. Repuntar lo que quedo apuntando a una copia, hacia la fila mas vieja.
--    Se hace antes de borrar para no perder ninguna referencia.
with primeras as (
  select path, min(created_at) as primera
  from ticspy.media_assets
  where path is not null
  group by path
),
canonica as (
  select m.id, m.path
  from ticspy.media_assets m
  join primeras p on p.path = m.path and p.primera = m.created_at
),
duplicadas as (
  select m.id as id_dup, c.id as id_ok
  from ticspy.media_assets m
  join canonica c on c.path = m.path
  where m.id <> c.id
)
update ticspy.brands b set media_id = d.id_ok
from duplicadas d where b.media_id = d.id_dup;

-- 2. Borrar las copias. El resto de las tablas referencia con
--    "on delete set null", asi que no se pierde ninguna fila de contenido.
delete from ticspy.media_assets m
using ticspy.media_assets otra
where m.path is not null
  and m.path = otra.path
  and m.created_at > otra.created_at;

-- Si dos copias comparten el mismo created_at al microsegundo, la de arriba
-- no las separa. Este segundo pase desempata por id.
delete from ticspy.media_assets m
using ticspy.media_assets otra
where m.path is not null
  and m.path = otra.path
  and m.created_at = otra.created_at
  and m.id > otra.id;

-- 3. El indice que faltaba.
--
--    Va sin "where path is not null" a proposito: un indice parcial no sirve
--    para "on conflict (path)" salvo que la sentencia repita la misma
--    condicion, y Postgres corta con 42P10. Un unique comun tampoco molesta,
--    porque los nulos no chocan entre si: un archivo externo sin path sigue
--    pudiendo convivir con otros.
drop index if exists ticspy.idx_media_path_unica;

create unique index if not exists idx_media_path_unica
  on ticspy.media_assets (path);
