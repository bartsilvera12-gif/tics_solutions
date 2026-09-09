-- ===========================================================================
--  Seed 004 :: los cuatro servicios que ya se veian en /servicios
-- ===========================================================================
--  Generado por supabase/tools/generar-seed-servicios.pl a partir del sitio.
--  No editar a mano: se pisa en la proxima corrida. Para cambiar un texto,
--  usar el panel.
--
--  El seed 001 los habia cargado con el titulo pero sin el texto, asi que en
--  el panel se veian vacios. Aca se completan.
--
--  Es idempotente: ON CONFLICT sobre el slug, que es unico.
-- ===========================================================================

INSERT INTO ticspy.services (slug, title, short_description, description, status, sort_order)
VALUES ('licenciamiento-de-software-cad', 'Licenciamiento de software CAD', 'Somos reseller autorizado de ZWCAD, Aplitop, CADprofi y ZW3D. Te ayudamos a elegir la edición que corresponde según cómo', 'Somos reseller autorizado de ZWCAD, Aplitop, CADprofi y ZW3D. Te ayudamos a elegir la edición que corresponde según cómo trabaja tu equipo, con licencia perpetua en lugar de suscripción.', 'published', 1)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title, short_description = EXCLUDED.short_description,
  description = EXCLUDED.description, status = EXCLUDED.status,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.services (slug, title, short_description, description, status, sort_order)
VALUES ('implementacion-y-capacitacion', 'Implementación y capacitación', 'Instalamos, migramos tus plantillas y personalizaciones, y capacitamos al equipo. El soporte lo damos acá, no por correo', 'Instalamos, migramos tus plantillas y personalizaciones, y capacitamos al equipo. El soporte lo damos acá, no por correo a otro país.', 'published', 2)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title, short_description = EXCLUDED.short_description,
  description = EXCLUDED.description, status = EXCLUDED.status,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.services (slug, title, short_description, description, status, sort_order)
VALUES ('proteccion-de-datos', 'Protección de datos', 'Blindamos tu información más valiosa con soluciones de respaldo y recuperación de vanguardia, para que tus datos estén s', 'Blindamos tu información más valiosa con soluciones de respaldo y recuperación de vanguardia, para que tus datos estén siempre seguros y accesibles.', 'published', 3)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title, short_description = EXCLUDED.short_description,
  description = EXCLUDED.description, status = EXCLUDED.status,
  sort_order = EXCLUDED.sort_order;

INSERT INTO ticspy.services (slug, title, short_description, description, status, sort_order)
VALUES ('monitoreo-y-gestion-de-riesgos', 'Monitoreo y gestión de riesgos', 'Vigilamos constantemente tu infraestructura para identificar y neutralizar posibles amenazas antes de que afecten tus op', 'Vigilamos constantemente tu infraestructura para identificar y neutralizar posibles amenazas antes de que afecten tus operaciones.', 'published', 4)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title, short_description = EXCLUDED.short_description,
  description = EXCLUDED.description, status = EXCLUDED.status,
  sort_order = EXCLUDED.sort_order;

