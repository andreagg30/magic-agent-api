CREATE TABLE policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  show_footer BOOLEAN NOT NULL DEFAULT FALSE,
  show_wp_description BOOLEAN NOT NULL DEFAULT FALSE,
  wp_description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_policies_description_length
    CHECK (char_length(description) <= 3600)
);

CREATE TRIGGER trg_policies_updated_at
BEFORE UPDATE ON policies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
