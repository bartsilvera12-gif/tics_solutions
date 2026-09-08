-- 003_create_indexes.sql
--
-- Indices y triggers de updated_at.

-- ===========================================================================
-- Indices
-- ===========================================================================
-- route y slug ya son UNIQUE, asi que su indice existe. Los de aca cubren
-- los filtros y ordenamientos que hace el sitio publico en cada carga.

CREATE INDEX IF NOT EXISTS idx_pages_status_sort            ON ticspy.pages (status, sort_order);
CREATE INDEX IF NOT EXISTS idx_pages_nav                    ON ticspy.pages (show_in_nav, sort_order) WHERE show_in_nav;

CREATE INDEX IF NOT EXISTS idx_page_sections_page           ON ticspy.page_sections (page_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_page_sections_visible        ON ticspy.page_sections (page_id) WHERE is_visible;

CREATE INDEX IF NOT EXISTS idx_section_items_section        ON ticspy.section_items (section_id, sort_order);

CREATE INDEX IF NOT EXISTS idx_services_status              ON ticspy.services (status);
CREATE INDEX IF NOT EXISTS idx_services_sort                ON ticspy.services (sort_order);
CREATE INDEX IF NOT EXISTS idx_services_category            ON ticspy.services (category_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_services_featured            ON ticspy.services (is_featured) WHERE is_featured;

CREATE INDEX IF NOT EXISTS idx_solutions_status             ON ticspy.solutions (status);
CREATE INDEX IF NOT EXISTS idx_solutions_unit               ON ticspy.solutions (unit_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_solutions_page               ON ticspy.solutions (page_id);

CREATE INDEX IF NOT EXISTS idx_solution_features_solution   ON ticspy.solution_features (solution_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_solution_features_group      ON ticspy.solution_features (solution_id, group_key, sort_order);

CREATE INDEX IF NOT EXISTS idx_solution_demos_solution      ON ticspy.solution_demos (solution_id, sort_order);

CREATE INDEX IF NOT EXISTS idx_brands_type                  ON ticspy.brands (brand_type);
CREATE INDEX IF NOT EXISTS idx_brands_sort                  ON ticspy.brands (sort_order);
CREATE INDEX IF NOT EXISTS idx_brands_type_status_sort      ON ticspy.brands (brand_type, status, sort_order);

CREATE INDEX IF NOT EXISTS idx_news_status                  ON ticspy.news_items (status);
CREATE INDEX IF NOT EXISTS idx_news_published_at            ON ticspy.news_items (published_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_news_solution                ON ticspy.news_items (solution_id, sort_order);

CREATE INDEX IF NOT EXISTS idx_nav_placement                ON ticspy.navigation_items (placement, sort_order);

CREATE INDEX IF NOT EXISTS idx_submissions_status           ON ticspy.contact_submissions (status);
CREATE INDEX IF NOT EXISTS idx_submissions_created          ON ticspy.contact_submissions (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_created                ON ticspy.audit_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_user                   ON ticspy.audit_logs (admin_user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_entity                 ON ticspy.audit_logs (entity_table, entity_id);

CREATE INDEX IF NOT EXISTS idx_media_provider               ON ticspy.media_assets (storage_provider);
CREATE INDEX IF NOT EXISTS idx_media_created                ON ticspy.media_assets (created_at DESC);

-- ===========================================================================
-- Triggers de updated_at
-- ===========================================================================
-- Se cuelgan por consulta al catalogo: cualquier tabla de ticspy que tenga la
-- columna queda cubierta, incluidas las que se agreguen mas adelante.

DO $$
DECLARE
  t RECORD;
BEGIN
  FOR t IN
    SELECT c.table_name
    FROM information_schema.columns c
    WHERE c.table_schema = 'ticspy'
      AND c.column_name = 'updated_at'
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_set_updated_at ON ticspy.%I;
       CREATE TRIGGER trg_set_updated_at
       BEFORE UPDATE ON ticspy.%I
       FOR EACH ROW EXECUTE FUNCTION ticspy.set_updated_at();',
      t.table_name, t.table_name
    );
  END LOOP;
END;
$$;
