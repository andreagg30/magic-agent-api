CREATE OR REPLACE FUNCTION add_product(
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
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_product_id UUID;
BEGIN
  INSERT INTO products (
    name,
    description,
    is_active,
    requires_date,
    requires_date_range,
    party_required,
    bday_required,
    product_type_id,
    icon
  ) VALUES (
    TRIM(p_name),
    NULLIF(TRIM(p_description), ''),
    p_is_active,
    COALESCE(p_date, FALSE),
    COALESCE(p_date_range, FALSE),
    COALESCE(p_party_required, FALSE),
    COALESCE(p_bday_required, FALSE),
    p_product_type_id,
    NULLIF(TRIM(p_icon), '')
  )
  RETURNING id INTO v_product_id;

  RETURN v_product_id;
END;
$$;
