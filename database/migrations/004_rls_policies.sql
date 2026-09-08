-- 004_rls_policies.sql
--
-- Funciones de autorizacion y politicas de fila.
--
-- Estado real verificado en esta instancia: PostgREST expone unicamente el
-- esquema public, asi que hoy ticspy NO es alcanzable desde la API de
-- Supabase. Igual se activa RLS: si manana alguien agrega ticspy a los
-- esquemas expuestos, las tablas no quedan abiertas de par en par.
--
-- El backend se conecta con el rol postgres, que es superusuario y salta RLS
-- por definicion. La autorizacion de verdad para el panel se resuelve en el
-- servidor, contra ticspy.admin_users. Esto es la red de contencion.

-- ---------------------------------------------------------------------------
-- Quien es administrador
-- ---------------------------------------------------------------------------
-- SECURITY DEFINER con search_path fijo: sin eso, un rol que pueda crear
-- objetos podria anteponer un esquema propio y hacer que la funcion resuelva
-- otra admin_users.

CREATE OR REPLACE FUNCTION ticspy.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ticspy, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1 FROM ticspy.admin_users a
    WHERE a.user_id = auth.uid() AND a.is_active
  );
$$;

COMMENT ON FUNCTION ticspy.is_admin() IS 'True si el usuario autenticado es un administrador activo.';

CREATE OR REPLACE FUNCTION ticspy.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ticspy, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1 FROM ticspy.admin_users a
    WHERE a.user_id = auth.uid() AND a.is_active AND a.role = 'super_admin'
  );
$$;

COMMENT ON FUNCTION ticspy.is_super_admin() IS 'True si el usuario autenticado es super_admin activo.';

-- ---------------------------------------------------------------------------
-- RLS en todas las tablas
-- ---------------------------------------------------------------------------

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'admin_users','media_assets','site_settings','pages','page_sections',
    'section_items','service_categories','services','solution_units','solutions',
    'solution_features','solution_demos','brands','news_items','navigation_items',
    'contact_submissions','audit_logs'
  ]
  LOOP
    EXECUTE format('ALTER TABLE ticspy.%I ENABLE ROW LEVEL SECURITY;', t);
    EXECUTE format('ALTER TABLE ticspy.%I FORCE ROW LEVEL SECURITY;', t);
  END LOOP;
END;
$$;

-- ---------------------------------------------------------------------------
-- Lectura publica: solo lo publicado y visible
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS lectura_publica ON ticspy.pages;
CREATE POLICY lectura_publica ON ticspy.pages
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.page_sections;
CREATE POLICY lectura_publica ON ticspy.page_sections
  FOR SELECT USING (is_visible AND EXISTS (
    SELECT 1 FROM ticspy.pages p WHERE p.id = page_id AND p.status = 'published'));

DROP POLICY IF EXISTS lectura_publica ON ticspy.section_items;
CREATE POLICY lectura_publica ON ticspy.section_items
  FOR SELECT USING (is_visible AND EXISTS (
    SELECT 1 FROM ticspy.page_sections s WHERE s.id = section_id AND s.is_visible));

DROP POLICY IF EXISTS lectura_publica ON ticspy.services;
CREATE POLICY lectura_publica ON ticspy.services
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.service_categories;
CREATE POLICY lectura_publica ON ticspy.service_categories
  FOR SELECT USING (is_active);

DROP POLICY IF EXISTS lectura_publica ON ticspy.solution_units;
CREATE POLICY lectura_publica ON ticspy.solution_units
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.solutions;
CREATE POLICY lectura_publica ON ticspy.solutions
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.solution_features;
CREATE POLICY lectura_publica ON ticspy.solution_features
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.solution_demos;
CREATE POLICY lectura_publica ON ticspy.solution_demos
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.brands;
CREATE POLICY lectura_publica ON ticspy.brands
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.news_items;
CREATE POLICY lectura_publica ON ticspy.news_items
  FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS lectura_publica ON ticspy.navigation_items;
CREATE POLICY lectura_publica ON ticspy.navigation_items
  FOR SELECT USING (is_visible);

DROP POLICY IF EXISTS lectura_publica ON ticspy.site_settings;
CREATE POLICY lectura_publica ON ticspy.site_settings
  FOR SELECT USING (true);

DROP POLICY IF EXISTS lectura_publica ON ticspy.media_assets;
CREATE POLICY lectura_publica ON ticspy.media_assets
  FOR SELECT USING (true);

-- Sin politica de lectura publica, a proposito:
--   contact_submissions  datos personales de quien escribe
--   audit_logs           rastro interno
--   admin_users          quienes administran el sitio

-- ---------------------------------------------------------------------------
-- Escritura: solo administradores
-- ---------------------------------------------------------------------------

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'media_assets','site_settings','pages','page_sections','section_items',
    'service_categories','services','solution_units','solutions',
    'solution_features','solution_demos','brands','news_items','navigation_items'
  ]
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS admin_total ON ticspy.%I;', t);
    EXECUTE format(
      'CREATE POLICY admin_total ON ticspy.%I FOR ALL
       USING (ticspy.is_admin()) WITH CHECK (ticspy.is_admin());', t);
  END LOOP;
END;
$$;

-- Las consultas las lee y gestiona un administrador. La insercion la hace el
-- backend con el rol postgres, que no pasa por estas politicas.
DROP POLICY IF EXISTS admin_total ON ticspy.contact_submissions;
CREATE POLICY admin_total ON ticspy.contact_submissions
  FOR ALL USING (ticspy.is_admin()) WITH CHECK (ticspy.is_admin());

-- La auditoria se lee, no se edita desde el panel.
DROP POLICY IF EXISTS admin_lectura ON ticspy.audit_logs;
CREATE POLICY admin_lectura ON ticspy.audit_logs
  FOR SELECT USING (ticspy.is_admin());

-- Cada administrador ve la lista; solo un super_admin la modifica.
DROP POLICY IF EXISTS admin_lectura ON ticspy.admin_users;
CREATE POLICY admin_lectura ON ticspy.admin_users
  FOR SELECT USING (ticspy.is_admin());

DROP POLICY IF EXISTS super_admin_escritura ON ticspy.admin_users;
CREATE POLICY super_admin_escritura ON ticspy.admin_users
  FOR ALL USING (ticspy.is_super_admin()) WITH CHECK (ticspy.is_super_admin());
