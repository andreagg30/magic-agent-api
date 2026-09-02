CREATE TABLE proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  response_id UUID REFERENCES form_responses(id) ON DELETE SET NULL,
  total NUMERIC(14, 2),
  total_type_id INTEGER REFERENCES catalog(id) ON DELETE SET NULL,
  status_id INTEGER REFERENCES catalog(id) ON DELETE SET NULL,
  show_party BOOLEAN,
  notes VARCHAR(500),
  gral_party_number INTEGER,
  gral_party_children INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE proposal_users (
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (proposal_id, user_id)
);

CREATE TABLE proposal_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  add_additional_info BOOLEAN,
  from_date DATE,
  to_date DATE,
  date DATE,
  new_party BOOLEAN,
  show_notes BOOLEAN,
  notes VARCHAR(500),
  position INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE proposal_party_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  proposal_product_id UUID REFERENCES proposal_products(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  last_name VARCHAR(50),
  name VARCHAR(50),
  dob DATE,
  position INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_proposals_response_id ON proposals(response_id);
CREATE INDEX idx_proposals_total_type_id ON proposals(total_type_id);
CREATE INDEX idx_proposals_status_id ON proposals(status_id);
CREATE INDEX idx_proposal_users_user_id ON proposal_users(user_id);
CREATE INDEX idx_proposal_products_proposal_id ON proposal_products(proposal_id);
CREATE INDEX idx_proposal_products_product_id ON proposal_products(product_id);
CREATE INDEX idx_proposal_party_members_proposal_id ON proposal_party_members(proposal_id);
CREATE INDEX idx_proposal_party_members_product_id ON proposal_party_members(proposal_product_id);
CREATE INDEX idx_proposal_party_members_user_id ON proposal_party_members(user_id);

CREATE TRIGGER trg_proposals_updated_at
BEFORE UPDATE ON proposals
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
