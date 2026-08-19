CREATE TABLE policy_forms (
  policy_id UUID NOT NULL REFERENCES policies(id) ON DELETE CASCADE,
  form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (policy_id, form_id)
);

CREATE INDEX idx_policy_forms_form_id ON policy_forms(form_id);
