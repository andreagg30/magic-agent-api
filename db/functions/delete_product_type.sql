CREATE OR REPLACE FUNCTION delete_product_type(p_product_type_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM product_types WHERE id = p_product_type_id;
  RETURN FOUND;
END;
$$;
--