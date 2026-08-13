CREATE TABLE form_response_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  response_section_id UUID NOT NULL REFERENCES form_response_sections(id) ON DELETE CASCADE,
  question_name TEXT,
  question_key TEXT,
  response TEXT,
  other_response TEXT,
  selected_option JSONB,
  selected_options JSONB,
  has_other BOOLEAN,
  raw_data JSONB NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_form_response_questions_section_id
  ON form_response_questions(response_section_id);
