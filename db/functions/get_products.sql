CREATE OR REPLACE FUNCTION get_products(p_product_type_id UUID DEFAULT NULL)
RETURNS TABLE (
  id UUID,
  name VARCHAR(50),
  description VARCHAR(250),
  "isActive" BOOLEAN,
  date BOOLEAN,
  "dateRange" BOOLEAN,
  "partyRequired" BOOLEAN,
  "bdayRequired" BOOLEAN,
  "productType" JSONB,
  icon VARCHAR(50),
  "createdAt" TIMESTAMPTZ,
  "updatedAt" TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    p.id,
    p.name,
    p.description,
    p.is_active AS "isActive",
    p.requires_date AS date,
    p.requires_date_range AS "dateRange",
    p.party_required AS "partyRequired",
    p.bday_required AS "bdayRequired",
    CASE
      WHEN pt.id IS NULL THEN NULL
      ELSE jsonb_build_object('value', pt.id, 'label', pt.name)
    END AS "productType",
    p.icon,
    p.created_at AS "createdAt",
    p.updated_at AS "updatedAt"
  FROM products p
  LEFT JOIN product_types pt ON pt.id = p.product_type_id
  WHERE p_product_type_id IS NULL
     OR p.product_type_id = p_product_type_id
  ORDER BY p.created_at DESC;
$$;
