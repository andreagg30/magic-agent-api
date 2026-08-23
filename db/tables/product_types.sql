CREATE TABLE product_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL,
  description VARCHAR(250),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_product_types_name_not_empty
    CHECK (char_length(TRIM(name)) > 0)
);

CREATE TRIGGER trg_product_types_updated_at
BEFORE UPDATE ON product_types
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
--