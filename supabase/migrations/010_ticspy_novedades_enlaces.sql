-- =====================================================================
--  Tic's Solutions — 010: enlaces en las novedades
-- =====================================================================
--  La pagina /novedades se conecta con news_items, y cada novedad del sitio
--  termina con uno o dos enlaces: el que lleva a la publicacion de LinkedIn
--  y, a veces, uno interno ("Conocer ZWCAD"). La tabla no tenia donde
--  guardarlos, asi que la pantalla del panel no podia reproducir lo que ya
--  se ve en la web.
--
--  Los dos son opcionales. Una novedad sin enlaces se muestra igual, solo
--  que sin el renglon de abajo.
-- =====================================================================

alter table ticspy.news_items add column if not exists link_url             text;
alter table ticspy.news_items add column if not exists link_label           text;
alter table ticspy.news_items add column if not exists secondary_link_url   text;
alter table ticspy.news_items add column if not exists secondary_link_label text;

comment on column ticspy.news_items.link_url is
  'Enlace principal, normalmente la publicacion en LinkedIn. Se abre en otra pestana.';
comment on column ticspy.news_items.secondary_link_url is
  'Enlace secundario, normalmente a una pagina del propio sitio (por ejemplo #/zwcad).';
