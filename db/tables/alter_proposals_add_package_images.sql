ALTER TABLE proposals
ADD COLUMN IF NOT EXISTS is_package BOOLEAN;

CREATE TABLE IF NOT EXISTS proposal_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  path TEXT NOT NULL,
  name TEXT,
  position INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_proposal_images_proposal_id
ON proposal_images(proposal_id);
