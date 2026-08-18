CREATE OR REPLACE FUNCTION get_catalog_items(p_category_code TEXT)
RETURNS TABLE (
  value INTEGER,
  label TEXT
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    c.id AS value,
    c.label
  FROM catalog c
  WHERE c.category_code = p_category_code
    AND c.is_active = TRUE
  ORDER BY c.id;
$$;