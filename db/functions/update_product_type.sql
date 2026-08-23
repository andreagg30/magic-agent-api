CREATE OR REPLACE FUNCTION update_product_type(
  p_product_type_id UUID,
  p_name TEXT,
  p_description TEXT,
  p_is_active BOOLEAN
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE product_types
  SET
    name = TRIM(p_name),
    description = NULLIF(TRIM(p_description), ''),
    is_active = p_is_active
  WHERE id = p_product_type_id;

  RETURN FOUND;
END;
$$;
--