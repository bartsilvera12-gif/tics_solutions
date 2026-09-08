-- 002_create_ticspy_tables.sql
--
-- Tablas del CMS. El orden importa: media_assets y admin_users van primero
-- porque casi todo lo demas las referencia.

-- ===========================================================================
-- Administradores
-- ===========================================================================
-- Sin contrasena: las credenciales viven en auth.users, de Supabase. Aca solo
-- se guarda quien tiene permiso y con que rol.

CREATE TABLE IF NOT EXISTS ticspy.admin_users (
  user_id       UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'editor' CHECK (role IN ('super_admin', 'editor')),
  is_active     BOOLEAN NOT NULL DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE ticspy.admin_users IS 'Quien puede entrar al panel. Las credenciales son de Supabase Auth.';
COMMENT ON COLUMN ticspy.admin_users.role IS 'super_admin: todo. editor: contenido, pero no administradores.';

-- ===========================================================================
-- Biblioteca multimedia
-- ===========================================================================
-- storage_provider distingue los 58 archivos que ya viven en el repositorio
-- ("local") de lo que se suba despues desde el panel ("supabase").

CREATE TABLE IF NOT EXISTS ticspy.media_assets (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_provider TEXT NOT NULL DEFAULT 'supabase' CHECK (storage_provider IN ('local', 'supabase', 'external')),
  bucket           TEXT,
  path             TEXT,
  public_url       TEXT NOT NULL,
  original_name    TEXT,
  mime_type        TEXT,
  size_bytes       BIGINT,
  width            INTEGER,
  height           INTEGER,
  alt_text         TEXT,
  created_by       UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON COLUMN ticspy.media_assets.storage_provider IS 'local: archivo del repositorio. supabase: subido desde el panel. external: URL de terceros.';

-- ===========================================================================
-- Configuracion general
-- ===========================================================================
-- Fila unica: el CHECK sobre singleton evita que existan dos configuraciones.

CREATE TABLE IF NOT EXISTS ticspy.site_settings (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  singleton              BOOLEAN NOT NULL DEFAULT true UNIQUE CHECK (singleton),
  company_name           TEXT,
  tagline                TEXT,
  years_experience       INTEGER,
  contact_name           TEXT,
  contact_role           TEXT,
  contact_email          TEXT,
  contact_phone_display  TEXT,
  contact_phone_e164     TEXT,
  whatsapp_number        TEXT,
  location               TEXT,
  logo_light_media_id    UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  logo_dark_media_id     UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  favicon_media_id       UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  default_og_media_id    UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  social_links           JSONB NOT NULL DEFAULT '{}'::jsonb,
  footer_text            TEXT,
  developed_by_label     TEXT,
  developed_by_url       TEXT,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by             UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL
);

-- ===========================================================================
-- Paginas
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.pages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT NOT NULL UNIQUE,
  route           TEXT NOT NULL UNIQUE,
  name            TEXT NOT NULL,
  nav_label       TEXT,
  seo_title       TEXT,
  seo_description TEXT,
  og_media_id     UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  status          TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  show_in_nav     BOOLEAN NOT NULL DEFAULT true,
  sort_order      INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by      UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  updated_by      UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL
);

COMMENT ON COLUMN ticspy.pages.route IS 'Ruta publica tal cual la usa el sitio hoy. No cambiar: romperia enlaces.';

-- ===========================================================================
-- Secciones de cada pagina
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.page_sections (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id              UUID NOT NULL REFERENCES ticspy.pages(id) ON DELETE CASCADE,
  section_key          TEXT NOT NULL,
  section_type         TEXT NOT NULL DEFAULT 'text' CHECK (section_type IN (
                         'hero','text','text_image','cards','benefits','brands',
                         'partners','gallery','video','cta','contact','legal','custom')),
  eyebrow              TEXT,
  title                TEXT,
  highlight_text       TEXT,
  subtitle             TEXT,
  body                 TEXT,
  media_id             UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  secondary_media_id   UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  cta_label            TEXT,
  cta_url              TEXT,
  secondary_cta_label  TEXT,
  secondary_cta_url    TEXT,
  style_variant        TEXT,
  settings             JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_visible           BOOLEAN NOT NULL DEFAULT true,
  sort_order           INTEGER NOT NULL DEFAULT 0,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by           UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  updated_by           UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  UNIQUE (page_id, section_key)
);

COMMENT ON COLUMN ticspy.page_sections.highlight_text IS 'El fragmento que va en rojo dentro del titulo.';
COMMENT ON COLUMN ticspy.page_sections.settings IS 'Ajustes sueltos. El panel los muestra como campos normales, no como JSON crudo.';

-- ===========================================================================
-- Elementos repetibles de una seccion
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.section_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id  UUID NOT NULL REFERENCES ticspy.page_sections(id) ON DELETE CASCADE,
  item_key    TEXT,
  eyebrow     TEXT,
  title       TEXT,
  body        TEXT,
  media_id    UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  badge       TEXT,
  link_label  TEXT,
  link_url    TEXT,
  settings    JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_visible  BOOLEAN NOT NULL DEFAULT true,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ===========================================================================
-- Servicios
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.service_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL UNIQUE,
  description TEXT,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ticspy.services (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id       UUID REFERENCES ticspy.service_categories(id) ON DELETE SET NULL,
  slug              TEXT NOT NULL UNIQUE,
  title             TEXT NOT NULL,
  short_description TEXT,
  description       TEXT,
  media_id          UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  cta_label         TEXT,
  cta_url           TEXT,
  is_featured       BOOLEAN NOT NULL DEFAULT false,
  status            TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  sort_order        INTEGER NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by        UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  updated_by        UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL
);

-- ===========================================================================
-- Soluciones
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.solution_units (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  eyebrow     TEXT,
  title       TEXT,
  description TEXT,
  route       TEXT,
  media_id    UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  status      TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ticspy.solutions (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id            UUID REFERENCES ticspy.solution_units(id) ON DELETE SET NULL,
  page_id            UUID REFERENCES ticspy.pages(id) ON DELETE SET NULL,
  slug               TEXT NOT NULL UNIQUE,
  name               TEXT NOT NULL,
  short_name         TEXT,
  version            TEXT,
  category           TEXT,
  eyebrow            TEXT,
  headline           TEXT,
  headline_highlight TEXT,
  intro              TEXT,
  logo_media_id      UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  hero_media_id      UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  banner_media_id    UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  cta_label          TEXT,
  cta_url            TEXT,
  legal_note         TEXT,
  status             TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  sort_order         INTEGER NOT NULL DEFAULT 0,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by         UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  updated_by         UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL
);

-- group_key separa las distintas grillas de una misma solucion: en ZWCAD, por
-- ejemplo, las novedades de la version conviven con los motivos para elegirlo.

CREATE TABLE IF NOT EXISTS ticspy.solution_features (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  solution_id UUID NOT NULL REFERENCES ticspy.solutions(id) ON DELETE CASCADE,
  group_key   TEXT,
  feature_key TEXT,
  label       TEXT,
  title       TEXT,
  description TEXT,
  bullets     JSONB NOT NULL DEFAULT '[]'::jsonb,
  media_id    UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  status      TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ticspy.solution_demos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  solution_id     UUID NOT NULL REFERENCES ticspy.solutions(id) ON DELETE CASCADE,
  slug            TEXT,
  title           TEXT,
  description     TEXT,
  video_media_id  UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  poster_media_id UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  status          TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  sort_order      INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ===========================================================================
-- Marcas y partners
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.brands (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id        UUID REFERENCES ticspy.solution_units(id) ON DELETE SET NULL,
  solution_id    UUID REFERENCES ticspy.solutions(id) ON DELETE SET NULL,
  brand_type     TEXT NOT NULL DEFAULT 'brand' CHECK (brand_type IN ('partner', 'brand')),
  name           TEXT NOT NULL,
  slug           TEXT NOT NULL UNIQUE,
  media_id       UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  route          TEXT,
  website_url    TEXT,
  display_height TEXT,
  status         TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  sort_order     INTEGER NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON COLUMN ticspy.brands.display_height IS 'Alto con el que se dibuja el logo en la cinta. Cada logo tiene proporcion distinta.';

-- ===========================================================================
-- Novedades
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.news_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  solution_id  UUID REFERENCES ticspy.solutions(id) ON DELETE SET NULL,
  slug         TEXT NOT NULL UNIQUE,
  title        TEXT NOT NULL,
  label        TEXT,
  summary      TEXT,
  body         TEXT,
  media_id     UUID REFERENCES ticspy.media_assets(id) ON DELETE SET NULL,
  status       TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  published_at TIMESTAMPTZ,
  sort_order   INTEGER NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by   UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  updated_by   UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL
);

-- ===========================================================================
-- Navegacion
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.navigation_items (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id  UUID REFERENCES ticspy.navigation_items(id) ON DELETE CASCADE,
  placement  TEXT NOT NULL CHECK (placement IN ('header', 'menu', 'footer')),
  label      TEXT NOT NULL,
  href       TEXT,
  is_visible BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ===========================================================================
-- Consultas del formulario
-- ===========================================================================
-- email_sent y auto_reply_sent quedan aparte a proposito: si el correo falla,
-- la consulta igual queda guardada y se ve en el panel.

CREATE TABLE IF NOT EXISTS ticspy.contact_submissions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  company         TEXT,
  email           TEXT NOT NULL,
  phone           TEXT,
  message         TEXT NOT NULL,
  source_route    TEXT,
  status          TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied', 'archived', 'spam')),
  email_sent      BOOLEAN NOT NULL DEFAULT false,
  auto_reply_sent BOOLEAN NOT NULL DEFAULT false,
  read_at         TIMESTAMPTZ,
  replied_at      TIMESTAMPTZ,
  internal_notes  TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ===========================================================================
-- Auditoria
-- ===========================================================================

CREATE TABLE IF NOT EXISTS ticspy.audit_logs (
  id            BIGSERIAL PRIMARY KEY,
  admin_user_id UUID REFERENCES ticspy.admin_users(user_id) ON DELETE SET NULL,
  action        TEXT NOT NULL,
  entity_table  TEXT,
  entity_id     TEXT,
  old_data      JSONB,
  new_data      JSONB,
  ip_address    TEXT,
  user_agent    TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE ticspy.audit_logs IS 'login, logout, create, update, delete, publish, unpublish, upload.';
