CREATE OR REPLACE FUNCTION update_term(p_term_id UUID, p_payload JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE terms SET
    name = TRIM(p_payload->>'name'),
    image = NULLIF(TRIM(p_payload->>'image'), ''),
    icon = TRIM(p_payload->>'icon'),
    description = NULLIF(p_payload->>'description', ''),
    is_active = COALESCE(
      NULLIF(p_payload->>'isActive', '')::BOOLEAN,
      is_active
    )
  WHERE id = p_term_id;

  IF NOT FOUND THEN RETURN FALSE; END IF;

  PERFORM sync_term_categories(p_term_id, p_payload->'categories');
  PERFORM sync_term_attributes(p_term_id, p_payload->'attributes');

  RETURN TRUE;
END;
$$;
