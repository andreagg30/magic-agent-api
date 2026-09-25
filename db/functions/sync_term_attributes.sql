CREATE OR REPLACE FUNCTION sync_term_attributes(
  p_term_id UUID,
  p_attributes JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM term_attributes WHERE term_id = p_term_id;

  IF jsonb_typeof(p_attributes) = 'array' THEN
    INSERT INTO term_attributes (term_id, label, value, position)
    SELECT
      p_term_id,
      attribute->>'label',
      attribute->>'value',
      ordinality - 1
    FROM jsonb_array_elements(p_attributes)
      WITH ORDINALITY AS entries(attribute, ordinality);
  END IF;
END;
$$;
