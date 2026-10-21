CREATE OR REPLACE FUNCTION update_course(p_course_id UUID, p_payload JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE courses SET
    title = TRIM(p_payload->>'title'),
    description = p_payload->>'description',
    image = NULLIF(TRIM(p_payload->>'image'), ''),
    is_active = COALESCE(
      NULLIF(p_payload->>'isActive', '')::BOOLEAN,
      is_active
    )
  WHERE id = p_course_id;

  IF NOT FOUND THEN RETURN FALSE; END IF;

  PERFORM sync_course_modules(p_course_id, p_payload->'modules');
  PERFORM sync_course_products(p_course_id, p_payload->'products');

  RETURN TRUE;
END;
$$;
