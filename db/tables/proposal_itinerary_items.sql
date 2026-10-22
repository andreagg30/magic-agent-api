CREATE TABLE proposal_itinerary_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  reminder TEXT,
  date TIMESTAMPTZ,
  position INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT chk_proposal_itinerary_items_name_not_empty
    CHECK (char_length(TRIM(name)) > 0)
);

CREATE INDEX idx_proposal_itinerary_items_proposal_id
ON proposal_itinerary_items(proposal_id);

CREATE INDEX idx_proposal_itinerary_items_date
ON proposal_itinerary_items(date);
