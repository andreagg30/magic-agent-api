CREATE OR REPLACE FUNCTION update_product(
  p_product_id UUID,
  p_name TEXT,
  p_description TEXT,
  p_is_active BOOLEAN,
  p_date BOOLEAN,
  p_date_range BOOLEAN,
  p_party_required BOOLEAN,
  p_bday_required BOOLEAN,
  p_product_type_id UUID,
  p_icon TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE products
  SET
    name = TRIM(p_name),
    description = NULLIF(TRIM(p_description), ''),
    is_active = p_is_active,
    requires_date = COALESCE(p_date, FALSE),
    requires_date_range = COALESCE(p_date_range, FALSE),
    party_required = COALESCE(p_party_required, FALSE),
    bday_required = COALESCE(p_bday_required, FALSE),
    product_type_id = p_product_type_id,
    icon = NULLIF(TRIM(p_icon), '')
  WHERE id = p_product_id;

  RETURN FOUND;
END;
$$;
