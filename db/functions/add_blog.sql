CREATE OR REPLACE FUNCTION add_blog(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_blog_id UUID;
BEGIN
  INSERT INTO blogs (title, image, short_description, is_active)
  VALUES (
    TRIM(p_payload->>'title'),
    NULLIF(TRIM(p_payload->>'image'), ''),
    NULLIF(p_payload->>'shortDescription', ''),
    COALESCE(NULLIF(p_payload->>'isActive', '')::BOOLEAN, TRUE)
  )
  RETURNING id INTO v_blog_id;

  PERFORM sync_blog_categories(v_blog_id, p_payload->'categories');
  PERFORM sync_blog_contents(v_blog_id, p_payload->'content');

  RETURN v_blog_id;
END;
$$;
