-- =====================================================================
--  Tic's Solutions — 006: bucket de Storage
-- =====================================================================
--  Bucket publico `tics-media` para lo que se suba desde el panel.
--  Publico porque las imagenes del sitio se sirven a visitantes anonimos:
--  no hay nada sensible ahi y un bucket privado obligaria a firmar cada URL.
--
--  La escritura, en cambio, esta cerrada: solo un administrador activo puede
--  subir, reemplazar o borrar. Igual que con las tablas, la regla vive en
--  Postgres y no en el panel.
--
--  Los 58 archivos que ya estan en el repositorio NO se mueven aca: quedan
--  registrados en media_assets como 'local' y se siguen sirviendo desde el
--  sitio. Mover 18 MB sin necesidad solo agrega un punto de falla.
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'tics-media', 'tics-media', true,
  26214400,   -- 25 MB: alcanza para los videos de demostracion que ya usa el sitio
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'video/mp4', 'video/webm']
)
on conflict (id) do update set
  public             = excluded.public,
  file_size_limit    = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ---------------------------------------------------------------------
-- Politicas del bucket
-- ---------------------------------------------------------------------
-- Se nombran con el prefijo del proyecto: storage.objects es una sola tabla
-- para toda la instancia, compartida con mas de cien sitios de NEURA.

drop policy if exists "ticspy lectura publica" on storage.objects;
create policy "ticspy lectura publica"
  on storage.objects for select
  using (bucket_id = 'tics-media');

drop policy if exists "ticspy alta admin" on storage.objects;
create policy "ticspy alta admin"
  on storage.objects for insert
  with check (bucket_id = 'tics-media' and ticspy.is_admin());

drop policy if exists "ticspy cambio admin" on storage.objects;
create policy "ticspy cambio admin"
  on storage.objects for update
  using (bucket_id = 'tics-media' and ticspy.is_admin())
  with check (bucket_id = 'tics-media' and ticspy.is_admin());

drop policy if exists "ticspy baja admin" on storage.objects;
create policy "ticspy baja admin"
  on storage.objects for delete
  using (bucket_id = 'tics-media' and ticspy.is_admin());
