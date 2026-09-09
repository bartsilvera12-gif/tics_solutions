-- ===========================================================================
--  Seed 002 :: textos de las secciones que no son de marca
-- ===========================================================================
--  Generado por supabase/tools/generar-seed-secciones.pl a partir del sitio.
--  No editar a mano: se pisa en la proxima corrida. Para cambiar un texto,
--  usar el panel; para cambiar el respaldo, tocar TEXTOS_SECCION en el sitio.
--
--  El titulo viaja entero y highlight_text dice que fragmento va en rojo. El
--  sitio parte la frase al pintarla, asi que la base nunca guarda HTML.
--
--  Es idempotente: ON CONFLICT sobre UNIQUE (page_id, section_key).
-- ===========================================================================

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'ciberseguridad', 'text', 'Que un incidente no te frene la operación.', 'frene la operación', 'Trabajamos sobre dos frentes que se complementan: evitar que la amenaza entre, y poder volver a trabajar rápido si algo pasa igual. Licenciamos, implementamos y acompañamos localmente las dos partes.', true, 1 FROM ticspy.pages WHERE slug = 'ciberseguridad'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'contacto', 'contact', 'Contactá con nosotros', 'nosotros', NULL, true, 1 FROM ticspy.pages WHERE slug = 'contacto'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'hero', 'hero', 'Impulsamos tu diseño. Protegemos tu operación.', 'Protegemos tu operación.', 'Software CAD para arquitectura, topografía, ingeniería y diseño de maquinarias, con licenciamiento, implementación y soporte local. Y la ciberseguridad para que nada de eso se detenga.', true, 1 FROM ticspy.pages WHERE slug = 'inicio'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'beneficios', 'benefits', 'Herramientas que tu equipo usa todos los días', 'usa todos los días', NULL, true, 2 FROM ticspy.pages WHERE slug = 'inicio'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'nosotros', 'text', '¿QUIÉNES SOMOS?', 'SOMOS?', 'Somos una empresa con 6 años de experiencia. Representamos en Paraguay el software CAD con el que trabajan los estudios de arquitectura, las constructoras y las empresas de topografía e ingeniería: lo licenciamos, lo implementamos y damos soporte acá. Y cuidamos que esa operación no se detenga, con respaldo y ciberseguridad.', true, 1 FROM ticspy.pages WHERE slug = 'nosotros'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'mision', 'text', 'Tu socio estratégico en el entorno digital', 'socio estratégico', 'Nuestra misión es ser tu socio estratégico en lo técnico. Te damos las herramientas con las que tu equipo diseña, calcula y documenta todos los días, y nos quedamos cerca para que rindan: eligiendo bien la licencia, poniéndola a andar y resolviendo cuando algo traba.', true, 2 FROM ticspy.pages WHERE slug = 'nosotros'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'novedades', 'text', 'En qué andamos.', 'andamos', 'Ferias, alianzas y novedades de las marcas que representamos.', true, 1 FROM ticspy.pages WHERE slug = 'novedades'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'partnersHome', 'partners', 'MARCAS Y SERVICIOS', 'SERVICIOS', 'Trabajamos con líderes del mercado para ofrecerte soluciones de la más alta calidad y confianza.', true, 1 FROM ticspy.pages WHERE slug = 'partners'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'servicios', 'text', 'NUESTROS SERVICIOS', 'SERVICIOS', 'Te ofrecemos un servicio completo y profesional. Nuestro equipo técnico cuenta con la experiencia y conocimientos necesarios que garantizan la correcta implementación de las soluciones y un acompañamiento constante en cada etapa.', true, 1 FROM ticspy.pages WHERE slug = 'servicios'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.page_sections (page_id, section_key, section_type, title, highlight_text, body, is_visible, sort_order)
SELECT id, 'unidadAec', 'text', 'CAD, topografía, electricidad y diseño de maquinarias.', 'diseño de maquinarias', 'Licenciamos, implementamos y damos soporte local al software técnico con el que trabajan los estudios de arquitectura, las constructoras y las empresas de topografía e ingeniería. Cada marca cubre una parte del flujo, y se complementan entre sí sobre el mismo dibujo.', true, 1 FROM ticspy.pages WHERE slug = 'unidad-aec'
ON CONFLICT (page_id, section_key) DO UPDATE SET
  title = EXCLUDED.title, highlight_text = EXCLUDED.highlight_text,
  body = EXCLUDED.body, section_type = EXCLUDED.section_type,
  sort_order = EXCLUDED.sort_order;

