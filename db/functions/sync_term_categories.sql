CREATE OR REPLACE FUNCTION sync_term_categories(
  p_term_id UUID,
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
      v_category_id := NULLIF(v_category->>'id', '')::INTEGER;

      IF v_category_id IS NULL THEN
        INSERT INTO term_categories (name)
        VALUES (TRIM(v_category->>'name'))
        RETURNING id INTO v_category_id;
      ELSIF NOT EXISTS (
        SELECT 1 FROM term_categories WHERE id = v_category_id
      ) THEN
        RAISE EXCEPTION 'InvalidTermCategoryId' USING ERRCODE = '23503';
      END IF;

      INSERT INTO term_category_links (term_id, category_id, position)
      VALUES (p_term_id, v_category_id, v_position)
      ON CONFLICT (term_id, category_id)
      DO UPDATE SET position = EXCLUDED.position;

      v_keep_ids := array_append(v_keep_ids, v_category_id);
      v_position := v_position + 1;
    END LOOP;
  END IF;

  SELECT COALESCE(array_agg(category_id), ARRAY[]::INTEGER[])
  INTO v_removed_ids
  FROM term_category_links
  WHERE term_id = p_term_id
    AND NOT (category_id = ANY(v_keep_ids));

  DELETE FROM term_category_links
  WHERE term_id = p_term_id
    AND NOT (category_id = ANY(v_keep_ids));

  DELETE FROM term_categories category
  WHERE category.id = ANY(v_removed_ids)
    AND NOT EXISTS (
      SELECT 1
      FROM term_category_links link
      WHERE link.category_id = category.id
    );
END;
$$;
