CREATE OR REPLACE FUNCTION add_product_type(
  p_name TEXT,
  p_description TEXT,
  p_is_active BOOLEAN
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_product_type_id UUID;
BEGIN
  INSERT INTO product_types (name, description, is_active)
  VALUES (
    TRIM(p_name),
    NULLIF(TRIM(p_description), ''),
    COALESCE(p_is_active, TRUE)
  )
  RETURNING id INTO v_product_type_id;

  RETURN v_product_type_id;
END;
$$;
--