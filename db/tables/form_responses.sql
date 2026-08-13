CREATE TABLE form_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
  status_id INTEGER NOT NULL REFERENCES catalog(id),
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_form_responses_form_id ON form_responses(form_id);
CREATE INDEX idx_form_responses_status_id ON form_responses(status_id);

-- Estados disponibles para una respuesta. Se puede consultar su id con:
-- SELECT id, label FROM catalog WHERE category_code = 'form_response_status';
INSERT INTO catalog (category_code, label) VALUES
  ('form_response_status', 'Visto'),
  ('form_response_status', 'Respondido'),
  ('form_response_status', 'Terminado'),
  ('form_response_status', 'Cancelado')
ON CONFLICT (category_code, label) DO NOTHING;
--