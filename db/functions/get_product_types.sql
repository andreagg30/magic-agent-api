CREATE OR REPLACE FUNCTION get_product_types()
RETURNS TABLE (
  id UUID,
  name VARCHAR(50),
  description VARCHAR(250),
  "isActive" BOOLEAN,
  "createdAt" TIMESTAMPTZ,
  "updatedAt" TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    pt.id,
    pt.name,
    pt.description,
    pt.is_active AS "isActive",
    pt.created_at AS "createdAt",
    pt.updated_at AS "updatedAt"
  FROM product_types pt
  ORDER BY pt.created_at DESC;
$$;
--