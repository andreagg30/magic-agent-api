ALTER TABLE proposals
  ADD COLUMN IF NOT EXISTS style_id INTEGER REFERENCES catalog(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_proposals_style_id ON proposals(style_id);
