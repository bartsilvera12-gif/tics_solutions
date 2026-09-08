-- 001_create_ticspy_schema.sql
--
-- Esta instancia de Supabase esta compartida con otros proyectos de NEURA:
-- el esquema public ya tiene decenas de tablas ajenas. Todo lo del CMS de
-- Tic's Solutions vive aislado en su propio esquema, y las consultas siempre
-- lo nombran de forma explicita en vez de confiar en el search_path.

CREATE SCHEMA IF NOT EXISTS ticspy;

COMMENT ON SCHEMA ticspy IS 'CMS del sitio de Tic''s Solutions (tics-py.com). No mezclar con public.';

-- Necesaria para gen_random_uuid(). En Supabase ya suele estar.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------------
-- Marca de tiempo de modificacion
-- ---------------------------------------------------------------------------
-- Una sola funcion para todas las tablas: el trigger la cuelga en cada una.
-- Asi ningun update se olvida de tocar updated_at.

CREATE OR REPLACE FUNCTION ticspy.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION ticspy.set_updated_at() IS 'Trigger BEFORE UPDATE: refresca updated_at.';

