-- ============================================================================
--  Tic's Solutions - contenido inicial del CMS
--
--  GENERADO. No editar a mano: se regenera con
--  .claude/generar-seed.pl leyendo "Sitio Web.dc.html".
--
--  Todo el contenido sale del sitio tal como esta publicado hoy. No se
--  reescribio, resumio ni tradujo nada.
--
--  Idempotente: ON CONFLICT sobre slug o route, asi que correrlo de nuevo
--  actualiza en vez de duplicar.
-- ============================================================================

set search_path = ticspy, public;

-- ---------------------------------------------------------------- media
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/aplitop-banner.jpg', './assets/aplitop-banner.jpg', 'aplitop-banner.jpg', 'image/jpeg', 24895)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/aplitop-campo.jpg', './assets/aplitop-campo.jpg', 'aplitop-campo.jpg', 'image/jpeg', 104622)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/aplitop-terreno.jpg', './assets/aplitop-terreno.jpg', 'aplitop-terreno.jpg', 'image/jpeg', 183453)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/automatizacion.mp4', './assets/cadprofi/automatizacion.mp4', 'automatizacion.mp4', 'video/mp4', 264874)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/baja-tension.mp4', './assets/cadprofi/baja-tension.mp4', 'baja-tension.mp4', 'video/mp4', 296359)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/bandejas.mp4', './assets/cadprofi/bandejas.mp4', 'bandejas.mp4', 'video/mp4', 267342)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/cadprofi-2026.webp', './assets/cadprofi/cadprofi-2026.webp', 'cadprofi-2026.webp', 'image/webp', 620594)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/energia.mp4', './assets/cadprofi/energia.mp4', 'energia.mp4', 'video/mp4', 683821)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/iluminacion.mp4', './assets/cadprofi/iluminacion.mp4', 'iluminacion.mp4', 'video/mp4', 341168)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/mapas.mp4', './assets/cadprofi/mapas.mp4', 'mapas.mp4', 'video/mp4', 536035)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/cadprofi/pararrayos.mp4', './assets/cadprofi/pararrayos.mp4', 'pararrayos.mp4', 'video/mp4', 232178)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/foto-ciberseguridad.jpg', './assets/foto-ciberseguridad.jpg', 'foto-ciberseguridad.jpg', 'image/jpeg', 307575)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/foto-identidad-digital.jpg', './assets/foto-identidad-digital.jpg', 'foto-identidad-digital.jpg', 'image/jpeg', 325922)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/logo-tics-blanco.png', './assets/logo-tics-blanco.png', 'logo-tics-blanco.png', 'image/png', 80285)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/logo-tics-oscuro.png', './assets/logo-tics-oscuro.png', 'logo-tics-oscuro.png', 'image/png', 58918)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/logo-tics.png', './assets/logo-tics.png', 'logo-tics.png', 'image/png', 94771)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/apc.png', './assets/marcas/apc.png', 'apc.png', 'image/png', 13202)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/aplitop.png', './assets/marcas/aplitop.png', 'aplitop.png', 'image/png', 13586)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/backup.png', './assets/marcas/arcserve/backup.png', 'backup.png', 'image/png', 6695)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/cloud-cyber-resilient-storage.png', './assets/marcas/arcserve/cloud-cyber-resilient-storage.png', 'cloud-cyber-resilient-storage.png', 'image/png', 5073)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/cloud-direct.png', './assets/marcas/arcserve/cloud-direct.png', 'cloud-direct.png', 'image/png', 6810)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/cloud-hybrid.png', './assets/marcas/arcserve/cloud-hybrid.png', 'cloud-hybrid.png', 'image/png', 8068)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/cloud-storage.png', './assets/marcas/arcserve/cloud-storage.png', 'cloud-storage.png', 'image/png', 4869)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/cyber-resilient-storage.png', './assets/marcas/arcserve/cyber-resilient-storage.png', 'cyber-resilient-storage.png', 'image/png', 4284)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/rha.png', './assets/marcas/arcserve/rha.png', 'rha.png', 'image/png', 5620)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/saas-backup.png', './assets/marcas/arcserve/saas-backup.png', 'saas-backup.png', 'image/png', 8411)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve/udp.png', './assets/marcas/arcserve/udp.png', 'udp.png', 'image/png', 5027)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/arcserve.png', './assets/marcas/arcserve.png', 'arcserve.png', 'image/png', 11837)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/cadprofi.png', './assets/marcas/cadprofi.png', 'cadprofi.png', 'image/png', 24846)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/dahua.png', './assets/marcas/dahua.png', 'dahua.png', 'image/png', 17570)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/dell.png', './assets/marcas/dell.png', 'dell.png', 'image/png', 17860)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/hpe.png', './assets/marcas/hpe.png', 'hpe.png', 'image/png', 11195)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/kaspersky.png', './assets/marcas/kaspersky.png', 'kaspersky.png', 'image/png', 39777)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/sonicwall.png', './assets/marcas/sonicwall.png', 'sonicwall.png', 'image/png', 11042)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/marcas/zwcad.png', './assets/marcas/zwcad.png', 'zwcad.png', 'image/png', 48064)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zw3d/capacidades.jpg', './assets/zw3d/capacidades.jpg', 'capacidades.jpg', 'image/jpeg', 144504)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zw3d/esp-chapa.jpg', './assets/zw3d/esp-chapa.jpg', 'esp-chapa.jpg', 'image/jpeg', 25206)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zw3d/esp-estructuras.jpg', './assets/zw3d/esp-estructuras.jpg', 'esp-estructuras.jpg', 'image/jpeg', 30265)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zw3d/esp-renderizado.jpg', './assets/zw3d/esp-renderizado.jpg', 'esp-renderizado.jpg', 'image/jpeg', 23061)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zw3d/esp-tuberias.jpg', './assets/zw3d/esp-tuberias.jpg', 'esp-tuberias.jpg', 'image/jpeg', 59566)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zw3d/formatos.jpg', './assets/zw3d/formatos.jpg', 'formatos.jpg', 'image/jpeg', 110514)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/agregar-seleccion.jpg', './assets/zwcad/agregar-seleccion.jpg', 'agregar-seleccion.jpg', 'image/jpeg', 46222)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/busqueda-similar.jpg', './assets/zwcad/busqueda-similar.jpg', 'busqueda-similar.jpg', 'image/jpeg', 50303)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/caja-herramientas.jpg', './assets/zwcad/caja-herramientas.jpg', 'caja-herramientas.jpg', 'image/jpeg', 32475)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/comparacion-2d.gif', './assets/zwcad/comparacion-2d.gif', 'comparacion-2d.gif', 'image/gif', 525809)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/comparacion-3d.mp4', './assets/zwcad/comparacion-3d.mp4', 'comparacion-3d.mp4', 'video/mp4', 11407349)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/cota-inteligente.jpg', './assets/zwcad/cota-inteligente.jpg', 'cota-inteligente.jpg', 'image/jpeg', 30265)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/escritorio-3d.jpg', './assets/zwcad/escritorio-3d.jpg', 'escritorio-3d.jpg', 'image/jpeg', 96947)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/extraccion-datos.jpg', './assets/zwcad/extraccion-datos.jpg', 'extraccion-datos.jpg', 'image/jpeg', 51622)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/ifc.jpg', './assets/zwcad/ifc.jpg', 'ifc.jpg', 'image/jpeg', 46199)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/importar-rvt.jpg', './assets/zwcad/importar-rvt.jpg', 'importar-rvt.jpg', 'image/jpeg', 31166)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/parametrico.jpg', './assets/zwcad/parametrico.jpg', 'parametrico.jpg', 'image/jpeg', 37998)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/pinzamientos.jpg', './assets/zwcad/pinzamientos.jpg', 'pinzamientos.jpg', 'image/jpeg', 30201)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/smart-match.jpg', './assets/zwcad/smart-match.jpg', 'smart-match.jpg', 'image/jpeg', 70666)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/smart-plot.jpg', './assets/zwcad/smart-plot.jpg', 'smart-plot.jpg', 'image/jpeg', 28744)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad/vista-seccion.jpg', './assets/zwcad/vista-seccion.jpg', 'vista-seccion.jpg', 'image/jpeg', 31728)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad-2026.jpg', './assets/zwcad-2026.jpg', 'zwcad-2026.jpg', 'image/jpeg', 177328)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.media_assets (storage_provider, path, public_url, original_name, mime_type, size_bytes)
VALUES ('local', 'assets/zwcad-modelo.jpg', './assets/zwcad-modelo.jpg', 'zwcad-modelo.jpg', 'image/jpeg', 208891)
ON CONFLICT DO NOTHING;

-- -------------------------------------------------------------- paginas
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('inicio', '/', 'Inicio', 'Inicio', 'published', true, 1)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('nosotros', '/nosotros', 'Nosotros', 'Nosotros', 'published', true, 2)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('servicios', '/servicios', 'Servicios', 'Servicios', 'published', true, 3)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('partners', '/partners', 'Partners', 'Soluciones', 'published', true, 4)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('unidad-aec', '/unidad-aec', 'Unidad AEC', 'Unidad AEC', 'published', true, 5)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('ciberseguridad', '/ciberseguridad', 'Ciberseguridad', 'Ciberseguridad', 'published', true, 6)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('zwcad', '/zwcad', 'ZWCAD', 'ZWCAD', 'published', true, 7)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('zw3d', '/zw3d', 'ZW3D WuKong 2027', 'ZW3D', 'published', true, 8)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('aplitop', '/aplitop', 'Aplitop', 'Aplitop', 'published', true, 9)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('cadprofi', '/cadprofi', 'CADprofi', 'CADprofi', 'published', true, 10)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('arcserve', '/arcserve', 'Arcserve', 'Arcserve', 'published', true, 11)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('novedades', '/novedades', 'Novedades', 'Novedades', 'published', true, 12)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('contacto', '/contacto', 'Contacto', 'Contactanos', 'published', true, 13)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.pages (slug, route, name, nav_label, status, show_in_nav, sort_order)
VALUES ('politicadeprivacidad', '/politicadeprivacidad', 'Politica de privacidad', 'Privacidad', 'published', false, 14)
ON CONFLICT (route) DO UPDATE SET name = EXCLUDED.name, nav_label = EXCLUDED.nav_label, sort_order = EXCLUDED.sort_order;

-- --------------------------------------------- unidades de solucion
INSERT INTO ticspy.solution_units (slug, name, eyebrow, title, route, status, sort_order) VALUES
  ('unidad-aec', 'Unidad AEC', '[ Unidad ] // Unidad AEC', 'CAD, topografía, electricidad y diseño de maquinarias.', '/unidad-aec', 'published', 1),
  ('ciberseguridad', 'Ciberseguridad', '[ Unidad ] // Ciberseguridad', 'Respaldo, recuperación y protección de los equipos.', '/ciberseguridad', 'published', 2)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, title = EXCLUDED.title;

-- ------------------------------------------------------------ soluciones
INSERT INTO ticspy.solutions (unit_id, page_id, slug, name, short_name, headline, headline_highlight, intro, status, sort_order)
VALUES ((SELECT id FROM ticspy.solution_units WHERE slug = 'unidad-aec'),
        (SELECT id FROM ticspy.pages WHERE route = '/zwcad'),
        'zwcad', 'ZWCAD', 'ZWCAD', 'Diseño CAD profesional.', NULL, 'ZWCAD es una potente solución CAD para dibujo 2D y navegación 3D. Totalmente compatible con DWG, permite una colaboración fluida entre distintas industrias, y su interfaz familiar ayuda a diseñar de forma más rápida. En Tic’s Solutions lo licenciamos, lo implementamos y te acompañamos localmente.', 'published', 1)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, headline = EXCLUDED.headline,
  headline_highlight = EXCLUDED.headline_highlight, intro = EXCLUDED.intro;
INSERT INTO ticspy.solutions (unit_id, page_id, slug, name, short_name, headline, headline_highlight, intro, status, sort_order)
VALUES ((SELECT id FROM ticspy.solution_units WHERE slug = 'unidad-aec'),
        (SELECT id FROM ticspy.pages WHERE route = '/zw3d'),
        'zw3d', 'ZW3D WuKong 2027', 'ZW3D', 'Del concepto a la manufactura, en un solo programa.', 'manufactura', 'ZW3D WuKong 2027 es la solución CAD 3D de ZWSOFT para diseño de maquinaria. Integra diseño, simulación y fabricación en una sola plataforma, así que la pieza que modelás es la misma que después se mecaniza, sin exportar de un programa a otro.', 'published', 2)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, headline = EXCLUDED.headline,
  headline_highlight = EXCLUDED.headline_highlight, intro = EXCLUDED.intro;
INSERT INTO ticspy.solutions (unit_id, page_id, slug, name, short_name, headline, headline_highlight, intro, status, sort_order)
VALUES ((SELECT id FROM ticspy.solution_units WHERE slug = 'unidad-aec'),
        (SELECT id FROM ticspy.pages WHERE route = '/aplitop'),
        'aplitop', 'Aplitop', 'Aplitop', 'Del dato de campo al proyecto terminado.', 'proyecto terminado', 'tcpMDT 26 potencia tu CAD con un entorno completo para topografía, ingeniería civil y modelado del terreno. Su diseño modular combina facilidad de uso, precisión y productividad, cubriendo desde el tratamiento de datos de campo hasta el diseño, mediciones, replanteo e intercambio BIM y GIS.', 'published', 3)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, headline = EXCLUDED.headline,
  headline_highlight = EXCLUDED.headline_highlight, intro = EXCLUDED.intro;
INSERT INTO ticspy.solutions (unit_id, page_id, slug, name, short_name, headline, headline_highlight, intro, status, sort_order)
VALUES ((SELECT id FROM ticspy.solution_units WHERE slug = 'unidad-aec'),
        (SELECT id FROM ticspy.pages WHERE route = '/cadprofi'),
        'cadprofi', 'CADprofi', 'CADprofi', 'Dejá de dibujar lo mismo dos veces.', 'lo mismo dos veces', 'CADprofi es un complemento que se instala sobre el CAD que ya usás y le agrega bibliotecas de símbolos y objetos normalizados, además de comandos específicos para cada especialidad. En lugar de redibujar cada elemento, lo insertás desde la biblioteca y el programa mantiene la coherencia del plano.', 'published', 4)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, headline = EXCLUDED.headline,
  headline_highlight = EXCLUDED.headline_highlight, intro = EXCLUDED.intro;
INSERT INTO ticspy.solutions (unit_id, page_id, slug, name, short_name, headline, headline_highlight, intro, status, sort_order)
VALUES ((SELECT id FROM ticspy.solution_units WHERE slug = 'ciberseguridad'),
        (SELECT id FROM ticspy.pages WHERE route = '/arcserve'),
        'arcserve', 'Arcserve', 'Arcserve', 'Que los datos vuelvan, pase lo que pase.', 'vuelvan', 'Arcserve cubre el respaldo y la recuperación de punta a punta: servidores físicos y virtuales, la nube y las plataformas donde hoy vive el trabajo diario. Estas son las soluciones de la línea, cada una para un escenario distinto.', 'published', 5)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, headline = EXCLUDED.headline,
  headline_highlight = EXCLUDED.headline_highlight, intro = EXCLUDED.intro;

-- ------------------------------------------------------ marcas y partners
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('partner', 'ZWCAD', 'partner-zwcad', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/zwcad.png'), '/zwcad', '34px', 'published', 1)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('partner', 'Aplitop', 'partner-aplitop', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/aplitop.png'), '/aplitop', '32px', 'published', 2)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('partner', 'CADprofi', 'partner-cadprofi', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/cadprofi.png'), '/cadprofi', '34px', 'published', 3)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('partner', 'Arcserve', 'partner-arcserve', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/arcserve.png'), '/arcserve', '28px', 'published', 4)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('partner', 'Kaspersky', 'partner-kaspersky', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/kaspersky.png'), NULL, '30px', 'published', 5)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('brand', 'Dell Technologies', 'brand-dell-technologies', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/dell.png'), NULL, '26px', 'published', 1)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('brand', 'Hewlett Packard Enterprise', 'brand-hewlett-packard-enterprise', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/hpe.png'), NULL, '60px', 'published', 2)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('brand', 'Dahua Technology', 'brand-dahua-technology', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/dahua.png'), NULL, '40px', 'published', 3)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('brand', 'APC by Schneider Electric', 'brand-apc-by-schneider-electric', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/apc.png'), NULL, '48px', 'published', 4)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;
INSERT INTO ticspy.brands (brand_type, name, slug, media_id, route, display_height, status, sort_order)
VALUES ('brand', 'SonicWall', 'brand-sonicwall', (SELECT id FROM ticspy.media_assets WHERE path = 'assets/marcas/sonicwall.png'), NULL, '28px', 'published', 5)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, media_id = EXCLUDED.media_id,
  route = EXCLUDED.route, display_height = EXCLUDED.display_height, sort_order = EXCLUDED.sort_order;

-- ----------------------------------- caracteristicas: novedades de ZWCAD
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'importar-rvt', 'Nuevo', 'Importación de RVT', 'Importá archivos RVT de las versiones 2015 a 2025: conserva parte de las propiedades del modelo y lo gestionás desde el administrador de capas.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/importar-rvt.jpg'), 'published', 1)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'vista-seccion', 'Nuevo', 'Vista de sección', 'Explorá modelos 3D seccionándolos por caja o por plano, para ver lo que queda adentro.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/vista-seccion.jpg'), 'published', 2)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'extraccion-datos', 'Nuevo', 'Extracción de datos', 'Extracción por lotes desde varios archivos a la vez, con más objetos y propiedades disponibles y plantillas que se reutilizan.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/extraccion-datos.jpg'), 'published', 3)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'ifc', 'Nuevo', 'Importar, editar y exportar IFC', 'Filtrá componentes al importar y exportá atributos propios, con recuperación del árbol de estructura y vinculación de referencias para trabajar con otras disciplinas sobre el mismo modelo.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/ifc.jpg'), 'published', 4)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'parametrico', 'Nuevo', 'Diseño paramétrico', 'Añadí restricciones geométricas y dimensionales a las entidades para ajustar rápidamente tamaño y forma, facilitando los cambios y la reutilización de dibujos.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/parametrico.jpg'), 'published', 5)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'caja-herramientas', 'Nuevo', 'Caja de herramientas ZWCAD', 'Accedé a herramientas de capas, cotas y selección en un único panel, con diseños personalizables.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/caja-herramientas.jpg'), 'published', 6)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'smart-match', 'Nuevo', 'Smart Match', 'Identificá automáticamente formas idénticas y editalas por lotes para mejorar la eficiencia.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/smart-match.jpg'), 'published', 7)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'cota-inteligente', 'Nuevo', 'Cota inteligente', 'Reconoce automáticamente los tipos de objeto y genera las cotas correspondientes, evitando cambiar de comando a cada paso.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/cota-inteligente.jpg'), 'published', 8)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'pinzamientos', 'Nuevo', 'Menú de pinzamientos de cota', 'Hacé clic en los pinzamientos para editar rápidamente cotas y textos por separado desde el menú.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/pinzamientos.jpg'), 'published', 9)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'agregar-seleccion', 'Nuevo', 'Agregar selección', 'Creá objetos con los mismos atributos básicos que los existentes para evitar tareas repetitivas.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/agregar-seleccion.jpg'), 'published', 10)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'busqueda-similar', 'Mejorado', 'Búsqueda similar', 'Reutilizá bloques históricos encontrando los similares, y ahorrá tiempo en cada dibujo.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/busqueda-similar.jpg'), 'published', 11)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, label, title, description, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zwcad'), 'novedades', 'smart-plot', 'Mejorado', 'Smart Plot', 'Interfaz optimizada y mayor eficiencia en el ploteo.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zwcad/smart-plot.jpg'), 'published', 12)
ON CONFLICT DO NOTHING;

-- ------------------------------ caracteristicas: diseno especializado ZW3D
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, title, bullets, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zw3d'), 'especializado', 'chapa', 'Diseño de chapa metálica', '["Herramientas profesionales para un diseño rápido de chapa metálica.","Soporta dobleces complejos y desplegado preciso, incorporando propiedades del material y tolerancias de doblado."]'::jsonb,
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zw3d/esp-chapa.jpg'), 'published', 1)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, title, bullets, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zw3d'), 'especializado', 'estructuras', 'Diseño de estructuras de acero', '["Acelera el proceso de modelado de estructuras de acero.","Soporta perfiles estándar y personalizados, soluciones de uniones en esquinas y elementos estructurales."]'::jsonb,
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zw3d/esp-estructuras.jpg'), 'published', 2)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, title, bullets, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zw3d'), 'especializado', 'tuberias', 'Diseño de tuberías', '["Simplifica el modelado de tuberías y la generación de dibujos.","Enrutamiento flexible, biblioteca de piezas estándar y colocación automática de bridas, empaques y uniones. Dibujos 2D con un solo clic."]'::jsonb,
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zw3d/esp-tuberias.jpg'), 'published', 3)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_features (solution_id, group_key, feature_key, title, bullets, media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'zw3d'), 'especializado', 'renderizado', 'Renderizado', '["Creá renderizados 3D fotorrealistas para comunicación visual.","Configuración mínima, con iluminación interactiva e iluminación global para mejorar el impacto visual."]'::jsonb,
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/zw3d/esp-renderizado.jpg'), 'published', 4)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------ demos: CADprofi electrico
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'energia', 'Instalaciones de energía eléctrica', 'El creador de esquemas arma el proyecto rápido: elegís productos en lugar de dibujar a mano, con plantillas listas de líneas, circuitos, cuadros eléctricos y arrancadores de motor.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/energia.mp4'), 'published', 1)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'baja-tension', 'Sistemas de extra baja tensión', 'Objetos listos para armarios IT y multimedia, y paneles de alarma contra incendios, para edificios residenciales, públicos e industriales.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/baja-tension.mp4'), 'published', 2)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'iluminacion', 'Equipos de instalación e iluminación', 'Numera los circuitos, les asigna los objetos y arma los cuadros y listas que reflejan esas conexiones. Exporta los locales a DIALux para el cálculo de iluminación.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/iluminacion.mp4'), 'published', 3)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'bandejas', 'Bandejas de cables y barras colectoras', 'Traza recorridos de bandejas y conductos de protección, con inserción automática de codos según los parámetros elegidos, y los elementos de sistemas de barras colectoras.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/bandejas.mp4'), 'published', 4)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'automatizacion', 'Automatización industrial y medición', 'Símbolos multivariantes para sistemas de control y medición: puntos de medición, sensores, transductores y controladores.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/automatizacion.mp4'), 'published', 5)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'mapas', 'Mapas, líneas y pilares', 'Biblioteca de símbolos, objetos y marcas para los planos de redes de transmisión y de telecomunicaciones.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/mapas.mp4'), 'published', 6)
ON CONFLICT DO NOTHING;
INSERT INTO ticspy.solution_demos (solution_id, slug, title, description, video_media_id, status, sort_order)
VALUES ((SELECT id FROM ticspy.solutions WHERE slug = 'cadprofi'), 'pararrayos', 'Protección contra rayos', 'Todo lo necesario para el sistema completo: mástiles, varillas, conductores, conectores, envolventes, electrodos de puesta a tierra y accesorios.',
        (SELECT id FROM ticspy.media_assets WHERE path = 'assets/cadprofi/pararrayos.mp4'), 'published', 7)
ON CONFLICT DO NOTHING;

-- -------------------------------------------------------- configuracion
INSERT INTO ticspy.site_settings (singleton, company_name, tagline, years_experience,
  contact_email, whatsapp_number, contact_phone_display, location)
VALUES (true, 'Tic''s Solutions', 'Tecnología a tu alcance', 6, 'arturo.osorio@tics-py.com', '595981171372', '(+595) 981 171 372', 'Paraguay')
ON CONFLICT (singleton) DO UPDATE SET company_name = EXCLUDED.company_name,
  tagline = EXCLUDED.tagline, years_experience = EXCLUDED.years_experience,
  contact_email = EXCLUDED.contact_email, whatsapp_number = EXCLUDED.whatsapp_number;

-- ----------------------------------------------------------- navegacion
INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)
VALUES ('header', 'Inicio', '#/', true, 1) ON CONFLICT DO NOTHING;
INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)
VALUES ('header', 'Nosotros', '#/nosotros', true, 2) ON CONFLICT DO NOTHING;
INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)
VALUES ('header', 'Servicios', '#/servicios', true, 3) ON CONFLICT DO NOTHING;
INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)
VALUES ('header', 'Soluciones', '#/partners', true, 4) ON CONFLICT DO NOTHING;
INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)
VALUES ('header', 'Novedades', '#/novedades', true, 5) ON CONFLICT DO NOTHING;
INSERT INTO ticspy.navigation_items (placement, label, href, is_visible, sort_order)
VALUES ('header', 'Contactanos', '#/contacto', true, 6) ON CONFLICT DO NOTHING;
