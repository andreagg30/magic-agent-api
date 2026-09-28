CREATE OR REPLACE FUNCTION delete_orphan_term_categories(
  p_category_ids INTEGER[]
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_category_ids IS NULL OR cardinality(p_category_ids) = 0 THEN
    RETURN;
  END IF;

  IF to_regclass('blog_category_links') IS NULL THEN
    DELETE FROM term_categories category
    WHERE category.id = ANY(p_category_ids)
      AND NOT EXISTS (
        SELECT 1 FROM term_category_links link
        WHERE link.category_id = category.id
      );
  ELSE
    EXECUTE $delete$
      DELETE FROM term_categories category
      WHERE category.id = ANY($1)
        AND NOT EXISTS (
          SELECT 1 FROM term_category_links link
          WHERE link.category_id = category.id
        )
        AND NOT EXISTS (
          SELECT 1 FROM blog_category_links link
          WHERE link.category_id = category.id
        )
    $delete$ USING p_category_ids;
  END IF;
END;
$$;
