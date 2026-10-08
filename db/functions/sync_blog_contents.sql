CREATE OR REPLACE FUNCTION sync_blog_contents(
  p_blog_id UUID,
  p_contents JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM blog_contents WHERE blog_id = p_blog_id;

  IF jsonb_typeof(p_contents) = 'array' THEN
    INSERT INTO blog_contents (
      blog_id, type_id, title, description, image, image_attributes,
      image_direction_id, content_index, position
    )
    SELECT
      p_blog_id,
      (content->'type'->>'value')::INTEGER,
      NULLIF(TRIM(content->>'title'), ''),
      NULLIF(content->>'description', ''),
      NULLIF(content->>'image', ''),
      CASE
        WHEN jsonb_typeof(content->'imageAttributes') = 'object'
          THEN content->'imageAttributes'
        ELSE NULL
      END,
      NULLIF(content->'imageDirection'->>'value', '')::INTEGER,
      (content->>'index')::INTEGER,
      ordinality - 1
    FROM jsonb_array_elements(p_contents)
      WITH ORDINALITY AS entries(content, ordinality);
  END IF;
END;
$$;
