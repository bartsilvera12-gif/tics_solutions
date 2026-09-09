-- ===========================================================================
--  Seed 006 :: titulo de pestaña por pagina
-- ===========================================================================
--  Hasta ahora las catorce rutas compartian el mismo titulo, porque estaba
--  escrito una sola vez en el marcado. En Google y en las pestañas del
--  navegador se veian todas iguales.
--
--  El titulo se arma con el nombre que ya tiene cada pagina y el de la
--  empresa. No es texto nuevo: es lo que el sitio ya decia, separado por
--  ruta. El inicio queda con el titulo general completo.
--
--  La descripcion se deja vacia a proposito. Es texto que conviene escribir
--  mirando cada pagina, y mientras tanto el sitio usa la general, que es
--  correcta. Se carga desde el panel, en Paginas.
-- ===========================================================================

UPDATE ticspy.pages
   SET seo_title = name || ' | Tic''s Solutions'
 WHERE slug <> 'inicio' AND COALESCE(seo_title, '') = '';

UPDATE ticspy.pages
   SET seo_title = 'Tic''s Solutions | Software CAD y Ciberseguridad en Paraguay'
 WHERE slug = 'inicio' AND COALESCE(seo_title, '') = '';
