CREATE OR REPLACE FUNCTION delete_blog(p_blog_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_category_ids INTEGER[];
BEGIN
  SELECT COALESCE(array_agg(category_id), ARRAY[]::INTEGER[])
  INTO v_category_ids
  FROM blog_category_links
  WHERE blog_id = p_blog_id;

  DELETE FROM blogs WHERE id = p_blog_id;
  IF NOT FOUND THEN RETURN FALSE; END IF;

  PERFORM delete_orphan_term_categories(v_category_ids);
  RETURN TRUE;
END;
$$;
