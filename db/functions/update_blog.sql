CREATE OR REPLACE FUNCTION update_blog(p_blog_id UUID, p_payload JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE blogs SET
    title = TRIM(p_payload->>'title'),
    image = NULLIF(TRIM(p_payload->>'image'), ''),
    short_description = NULLIF(p_payload->>'shortDescription', ''),
    is_active = COALESCE(
      NULLIF(p_payload->>'isActive', '')::BOOLEAN,
      is_active
    )
  WHERE id = p_blog_id;

  IF NOT FOUND THEN RETURN FALSE; END IF;

  PERFORM sync_blog_categories(p_blog_id, p_payload->'categories');
  PERFORM sync_blog_contents(p_blog_id, p_payload->'content');

  RETURN TRUE;
END;
$$;
