CREATE OR REPLACE FUNCTION add_course(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_course_id UUID;
BEGIN
  INSERT INTO courses (title, description, image, is_active)
  VALUES (
    TRIM(p_payload->>'title'),
    p_payload->>'description',
    NULLIF(TRIM(p_payload->>'image'), ''),
    COALESCE(NULLIF(p_payload->>'isActive', '')::BOOLEAN, TRUE)
  )
  RETURNING id INTO v_course_id;

  PERFORM sync_course_modules(v_course_id, p_payload->'modules');
  PERFORM sync_course_products(v_course_id, p_payload->'products');

  RETURN v_course_id;
END;
$$;
