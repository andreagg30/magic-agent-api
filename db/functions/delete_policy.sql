CREATE OR REPLACE FUNCTION delete_policy(p_policy_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM policies WHERE id = p_policy_id;
  RETURN FOUND;
END;
$$;
