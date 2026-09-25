CREATE OR REPLACE FUNCTION delete_term(p_term_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_category_ids INTEGER[];
BEGIN
  SELECT COALESCE(array_agg(category_id), ARRAY[]::INTEGER[])
  INTO v_category_ids
  FROM term_category_links
  WHERE term_id = p_term_id;

  DELETE FROM terms WHERE id = p_term_id;
  IF NOT FOUND THEN RETURN FALSE; END IF;

  DELETE FROM term_categories category
  WHERE category.id = ANY(v_category_ids)
    AND NOT EXISTS (
      SELECT 1
      FROM term_category_links link
      WHERE link.category_id = category.id
    );

  RETURN TRUE;
END;
$$;
