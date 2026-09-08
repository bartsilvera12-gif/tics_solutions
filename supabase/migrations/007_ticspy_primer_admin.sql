-- =====================================================================
--  Tic's Solutions — 007: alta del primer administrador
-- =====================================================================
--  IMPORTANTE, leer antes de ejecutar.
--
--  Esta migracion NO crea el usuario ni define ninguna contrasena. El
--  usuario se crea antes, a mano, desde el panel de Supabase:
--
--    Authentication -> Users -> Add user
--      Email:    el que corresponda
--      Password: la elegis vos en ese formulario, no va en ningun archivo
--      Marcar "Auto Confirm User"
--
--  Recien despues se corre este SQL, que busca ese usuario por email en
--  auth.users y le da el perfil de super_admin. Asi:
--
--    * la contrasena queda hasheada por Supabase Auth y nunca pasa por el
--      repositorio ni por el historial de git;
--    * no se inventa ningun UUID: se usa el que Auth ya asigno.
--
--  Si el email todavia no existe, avisa y no hace nada, en vez de fallar a
--  la mitad.
--
--  CAMBIAR el correo de abajo por el que se vaya a usar.
-- =====================================================================

do $blk$
declare
  correo  constant text := 'admin@ticspy.com';
  -- El apostrofo va doblado: si no, cierra la cadena y el bloque no compila.
  nombre  constant text := 'Administrador Tic''s Solutions';
  id_auth uuid;
begin
  select id into id_auth from auth.users where email = correo;

  if id_auth is null then
    raise warning
      'No existe el usuario % en auth.users. Crealo primero desde Authentication -> Users -> Add user y volve a correr esta migracion.',
      correo;
    return;
  end if;

  insert into ticspy.admin_users (user_id, full_name, role, is_active)
  values (id_auth, nombre, 'super_admin', true)
  on conflict (user_id) do update set
    full_name = excluded.full_name,
    role      = 'super_admin',
    is_active = true;

  raise notice 'Listo: % quedo como super_admin del panel.', correo;
end
$blk$;
