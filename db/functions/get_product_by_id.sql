CREATE OR REPLACE FUNCTION get_product_by_id(p_product_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT to_jsonb(p) || jsonb_build_object(
    'contents', get_product_contents(p.id)
  )
  FROM get_products(NULL::uuid) p
  WHERE p.id = p_product_id;
$$;
