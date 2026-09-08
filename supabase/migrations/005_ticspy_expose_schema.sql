-- ============================================================================
--  Tic's Solutions - Exponer el schema `ticspy` en PostgREST
--
--  La instancia de api.neura.com.py esta compartida por mas de cien
--  proyectos. PostgREST toma su configuracion del rol `authenticator` en la
--  propia base, asi que esto se aplica por SQL: no hay que entrar al
--  servidor ni reiniciar contenedores.
--
--  APPENDEA a la lista existente. Nunca la reescribe: si se pisara, los demas
--  proyectos de la instancia dejarian de responder.
--
--  Idempotente: correrlo dos veces no duplica el schema.
--  Mismo patron que Actitud_y_Tendencia y Panel_Hito.
-- ============================================================================

-- ATENCION, esto ya rompio la instancia una vez.
--
-- En api.neura.com.py la lista de schemas NO esta en el rol: la manda el
-- entorno de PostgREST (PGRST_DB_SCHEMAS). El rol no tiene nada, asi que
-- leerlo devuelve null.
--
-- Si en ese caso se escribe igual, el `alter role` PISA la configuracion del
-- entorno con lo poco que uno puso, y los mas de cien proyectos de la
-- instancia se quedan sin API al instante. Paso exactamente eso: la lista
-- quedo en 4 schemas hasta que se reviritio con
--   alter role authenticator reset pgrst.db_schemas;
--
-- Por eso este bloque solo appendea cuando YA hay una lista en el rol. Si no
-- la hay, aborta y no toca nada.

do $$
declare
  actual text;
  nuevo  text;
begin
  select (regexp_match(array_to_string(rolconfig, E'\n'), 'pgrst\.db_schemas=([^\n]*)'))[1]
    into actual
  from pg_roles
  where rolname = 'authenticator';

  if actual is null then
    raise exception
      'El rol authenticator no tiene pgrst.db_schemas: la lista viene del entorno de PostgREST. Escribirla aca la pisaria y dejaria sin API al resto de los proyectos. Agregar "ticspy" a PGRST_DB_SCHEMAS en el entorno del servidor, o pasar a este archivo la lista completa vigente antes de correrlo.';
  end if;

  if (',' || replace(actual, ' ', '') || ',') like '%,ticspy,%' then
    raise notice 'ticspy ya estaba expuesto: no se toca nada';
    return;
  end if;

  nuevo := actual || ',ticspy';
  execute format('alter role authenticator set pgrst.db_schemas = %L', nuevo);
  raise notice 'pgrst.db_schemas => % schemas', array_length(string_to_array(nuevo, ','), 1);
end $$;

-- ----------------------------------------------------------------------------
-- Permisos sobre el schema
-- ----------------------------------------------------------------------------
-- Exponerlo no alcanza: los roles de PostgREST tienen que poder verlo. Que
-- puedan leer o escribir cada fila lo sigue decidiendo RLS, no estos GRANT.

grant usage on schema ticspy to anon, authenticated, service_role;

grant select on all tables in schema ticspy to anon, authenticated;
grant insert, update, delete on all tables in schema ticspy to authenticated;
grant all on all sequences in schema ticspy to authenticated, service_role;
grant all on all tables in schema ticspy to service_role;

-- Lo que se cree mas adelante hereda los mismos permisos.
alter default privileges in schema ticspy grant select on tables to anon, authenticated;
alter default privileges in schema ticspy grant insert, update, delete on tables to authenticated;
alter default privileges in schema ticspy grant all on tables to service_role;
alter default privileges in schema ticspy grant all on sequences to authenticated, service_role;

-- Las funciones de autorizacion las llama RLS en nombre del usuario.
grant execute on function ticspy.is_admin() to anon, authenticated;
grant execute on function ticspy.is_super_admin() to anon, authenticated;

-- Recarga la configuracion de PostgREST sin reiniciar el servicio.
notify pgrst, 'reload config';
notify pgrst, 'reload schema';

-- Verificacion:
--   select (regexp_match(array_to_string(rolconfig, E'\n'), 'pgrst\.db_schemas=([^\n]*)'))[1]
--   from pg_roles where rolname = 'authenticator';
