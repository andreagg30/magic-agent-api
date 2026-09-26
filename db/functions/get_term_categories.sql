DROP FUNCTION IF EXISTS get_term_categories();

CREATE FUNCTION get_term_categories()
RETURNS TABLE (
  value INTEGER,
  label VARCHAR(100)
)
LANGUAGE sql
STABLE
AS $$
  SELECT DISTINCT ON (LOWER(TRIM(category.name)))
    category.id AS value,
    category.name AS label
  FROM term_categories category
  ORDER BY LOWER(TRIM(category.name)), category.id;
$$;
