CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL,
  description VARCHAR(250),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  requires_date BOOLEAN NOT NULL DEFAULT FALSE,
  requires_date_range BOOLEAN NOT NULL DEFAULT FALSE,
  party_required BOOLEAN NOT NULL DEFAULT FALSE,
  bday_required BOOLEAN NOT NULL DEFAULT FALSE,
  product_type_id UUID REFERENCES product_types(id) ON DELETE SET NULL,
  icon VARCHAR(50),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_products_name_not_empty
    CHECK (char_length(TRIM(name)) > 0),
  CONSTRAINT chk_products_date_mode
    CHECK (NOT (requires_date AND requires_date_range)),
  CONSTRAINT chk_products_bday_requires_party
    CHECK (NOT bday_required OR party_required)
);

CREATE INDEX idx_products_product_type_id ON products(product_type_id);

CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
