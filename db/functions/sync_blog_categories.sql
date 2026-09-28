CREATE OR REPLACE FUNCTION sync_blog_categories(
  p_blog_id UUID,
  p_categories JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_category JSONB;
  v_category_id INTEGER;
  v_position INTEGER := 0;
  v_keep_ids INTEGER[] := ARRAY[]::INTEGER[];
  v_removed_ids INTEGER[] := ARRAY[]::INTEGER[];
BEGIN
  IF jsonb_typeof(p_categories) = 'array' THEN
    FOR v_category IN SELECT value FROM jsonb_array_elements(p_categories) LOOP
      v_category_id := NULLIF(v_category->>'value', '')::INTEGER;

      IF v_category_id IS NULL THEN
        INSERT INTO term_categories (name)
        VALUES (TRIM(v_category->>'name'))
        RETURNING id INTO v_category_id;
      ELSIF NOT EXISTS (
        SELECT 1 FROM term_categories WHERE id = v_category_id
      ) THEN
        RAISE EXCEPTION 'InvalidBlogCategoryId' USING ERRCODE = '23503';
      END IF;

      INSERT INTO blog_category_links (blog_id, category_id, position)
      VALUES (p_blog_id, v_category_id, v_position)
      ON CONFLICT (blog_id, category_id)
      DO UPDATE SET position = EXCLUDED.position;

      v_keep_ids := array_append(v_keep_ids, v_category_id);
      v_position := v_position + 1;
    END LOOP;
  END IF;

  SELECT COALESCE(array_agg(category_id), ARRAY[]::INTEGER[])
  INTO v_removed_ids
  FROM blog_category_links
  WHERE blog_id = p_blog_id
    AND NOT (category_id = ANY(v_keep_ids));

  DELETE FROM blog_category_links
  WHERE blog_id = p_blog_id
    AND NOT (category_id = ANY(v_keep_ids));

  PERFORM delete_orphan_term_categories(v_removed_ids);
END;
$$;
