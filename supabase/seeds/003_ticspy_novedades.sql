-- ===========================================================================
--  Seed 003 :: las novedades que ya se veian en /novedades
-- ===========================================================================
--  Generado por supabase/tools/generar-seed-novedades.pl a partir del sitio.
--  No editar a mano: se pisa en la proxima corrida. Para cargar una novedad
--  nueva, usar el panel.
--
--  La fecha se guarda al mediodia y no a la medianoche: guardada a las 00:00
--  UTC, en Paraguay caeria el dia anterior.
--
--  Es idempotente: ON CONFLICT sobre el slug, que es unico.
-- ===========================================================================

INSERT INTO ticspy.news_items (slug, title, label, summary, published_at,
  link_url, link_label, secondary_link_url, secondary_link_label, status)
VALUES ('estuvimos-en-constructecnia-2026', 'Estuvimos en Constructecnia 2026', 'Evento', 'Una semana intensa de visitas a clientes del sector público y privado, y participación en la feria. Compartimos las novedades de ZWCAD junto al equipo de ZWSOFT que vino desde México y al director de ZWCAD para Argentina, Paraguay y Uruguay, y conversamos con profesionales del rubro sobre lo que necesita el mercado local.', '2026-05-25 12:00:00+00'::timestamptz,
  'https://www.linkedin.com/posts/arturo-miguel-osorio-c%C3%A9spedes-62717a36_luego-de-una-semana-intensa-y-muy-fruct%C3%ADfera-ugcPost-7464764864838914048-l-wA', 'Ver la publicación en LinkedIn', NULL, NULL, 'published')
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title, label = EXCLUDED.label, summary = EXCLUDED.summary,
  published_at = EXCLUDED.published_at, link_url = EXCLUDED.link_url,
  link_label = EXCLUDED.link_label,
  secondary_link_url = EXCLUDED.secondary_link_url,
  secondary_link_label = EXCLUDED.secondary_link_label,
  status = EXCLUDED.status;

INSERT INTO ticspy.news_items (slug, title, label, summary, published_at,
  link_url, link_label, secondary_link_url, secondary_link_label, status)
VALUES ('somos-reseller-autorizado-de-zwcad-en-paraguay', 'Somos reseller autorizado de ZWCAD en Paraguay', 'Alianza', 'Arranca una nueva etapa de ZWCAD en el país, de la mano de Tic’s Solutions. Es una herramienta ágil y potente, que no consume muchos recursos, y con licenciamiento perpetuo: se paga una vez y se sigue trabajando sin estar pendiente de que venza una suscripción.', '2026-04-15 12:00:00+00'::timestamptz,
  'https://www.linkedin.com/posts/arturo-miguel-osorio-c%C3%A9spedes-62717a36_muchas-gracias-por-la-bienvenida-don-alfredo-activity-7450252190016892930-prbj', 'Ver la publicación en LinkedIn', '#/zwcad', 'Conocer ZWCAD', 'published')
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title, label = EXCLUDED.label, summary = EXCLUDED.summary,
  published_at = EXCLUDED.published_at, link_url = EXCLUDED.link_url,
  link_label = EXCLUDED.link_label,
  secondary_link_url = EXCLUDED.secondary_link_url,
  secondary_link_label = EXCLUDED.secondary_link_label,
  status = EXCLUDED.status;

