ALTER TABLE proposals ADD COLUMN IF NOT EXISTS add_extras BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE proposals ADD COLUMN IF NOT EXISTS add_variations BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS proposal_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN ('extras', 'variations')),
  description VARCHAR(400),
  total NUMERIC(14,2),
  position INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_proposal_options_proposal ON proposal_options(proposal_id, kind);
CREATE TABLE IF NOT EXISTS proposal_option_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  option_id UUID NOT NULL REFERENCES proposal_options(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  add_additional_info BOOLEAN,
  from_date DATE,
  to_date DATE,
  date DATE,
  show_notes BOOLEAN,
  notes VARCHAR(150),
  position INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_proposal_option_products_option ON proposal_option_products(option_id);
