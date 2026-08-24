CREATE OR REPLACE FUNCTION delete_product(p_product_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM products WHERE id = p_product_id;
  RETURN FOUND;
END;
$$;
