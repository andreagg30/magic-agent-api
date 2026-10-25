CREATE TABLE IF NOT EXISTS product_contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  type_id INTEGER NOT NULL REFERENCES catalog(id),
  title VARCHAR(100),
  button_text VARCHAR(60),
  go_to TEXT,
  description TEXT,
  image TEXT,
  image_attributes JSONB,
  image_direction_id INTEGER REFERENCES catalog(id),
  content_index INTEGER NOT NULL,
  position INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_product_contents_product_id ON product_contents(product_id);
