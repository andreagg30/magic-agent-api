CREATE TABLE form_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id UUID NOT NULL REFERENCES form_sections(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  type_value TEXT NOT NULL,
  type_label TEXT,
  is_required BOOLEAN NOT NULL DEFAULT FALSE,
  add_additional_info BOOLEAN NOT NULL DEFAULT FALSE,
  additional_info TEXT,
  add_image BOOLEAN NOT NULL DEFAULT FALSE,
  image_path TEXT,
  image_name TEXT,
  max_length INTEGER,
  has_other BOOLEAN NOT NULL DEFAULT FALSE,
  other_section JSONB,
  add_extra_validations BOOLEAN NOT NULL DEFAULT FALSE,
  short_text_validations JSONB,
  checkbox_validations JSONB,
  option_validations JSONB,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_form_questions_updated_at
BEFORE UPDATE ON form_questions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

--
