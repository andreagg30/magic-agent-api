CREATE OR REPLACE FUNCTION add_term(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_term_id UUID;
BEGIN
  INSERT INTO terms (name, image, icon, description, is_active)
  VALUES (
    TRIM(p_payload->>'name'),
    NULLIF(TRIM(p_payload->>'image'), ''),
    TRIM(p_payload->>'icon'),
    NULLIF(p_payload->>'description', ''),
    COALESCE(NULLIF(p_payload->>'isActive', '')::BOOLEAN, TRUE)
  )
  RETURNING id INTO v_term_id;

  PERFORM sync_term_categories(v_term_id, p_payload->'categories');
  PERFORM sync_term_attributes(v_term_id, p_payload->'attributes');

  RETURN v_term_id;
END;
$$;
