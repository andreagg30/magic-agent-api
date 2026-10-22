CREATE OR REPLACE FUNCTION update_user(p_user_id UUID, p_data JSONB)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
  -- Serialize email changes even in installations without the unique email index.
  LOCK TABLE users IN SHARE ROW EXCLUSIVE MODE;
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id) THEN
    RETURN NULL;
  END IF;

  IF p_data ? 'email' AND EXISTS (
    SELECT 1 FROM users
    WHERE LOWER(email) = LOWER(TRIM(p_data->>'email')) AND id <> p_user_id
  ) THEN
    RAISE EXCEPTION 'EmailAlreadyRegistered' USING ERRCODE = '23505';
  END IF;

  IF p_data ? 'user_type_id' AND NOT EXISTS (
    SELECT 1 FROM catalog
    WHERE id = (p_data->>'user_type_id')::INTEGER AND category_code = 'user_type'
  ) THEN
    RAISE EXCEPTION 'InvalidUserType' USING ERRCODE = '22023';
  END IF;

  UPDATE users SET
    first_name = CASE WHEN p_data ? 'first_name' THEN p_data->>'first_name' ELSE first_name END,
    last_name = CASE WHEN p_data ? 'last_name' THEN p_data->>'last_name' ELSE last_name END,
    email = CASE WHEN p_data ? 'email' THEN LOWER(TRIM(p_data->>'email')) ELSE email END,
    phone = CASE WHEN p_data ? 'phone' THEN p_data->>'phone' ELSE phone END,
    password_hash = CASE WHEN p_data ? 'password_hash' THEN p_data->>'password_hash' ELSE password_hash END,
    user_type_id = CASE WHEN p_data ? 'user_type_id' THEN (p_data->>'user_type_id')::INTEGER ELSE user_type_id END,
    email_verified = CASE WHEN p_data ? 'email_verified' THEN (p_data->>'email_verified')::BOOLEAN ELSE email_verified END,
    is_active = CASE WHEN p_data ? 'is_active' THEN (p_data->>'is_active')::BOOLEAN ELSE is_active END,
    updated_at = NOW()
  WHERE id = p_user_id;

  RETURN get_user_by_id_with_proposals(p_user_id);
END;
$$;
