CREATE TABLE form_response_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  response_id UUID NOT NULL REFERENCES form_responses(id) ON DELETE CASCADE,
  section_name TEXT NOT NULL,
  section_step INTEGER NOT NULL,
  section JSONB,
  raw_data JSONB NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_form_response_sections_response_id
  ON form_response_sections(response_id);
