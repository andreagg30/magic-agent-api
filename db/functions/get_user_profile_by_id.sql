-- Restore the profile return type after moving courses to GET /users/:id.
BEGIN;
DROP FUNCTION IF EXISTS get_user_profile_by_id(UUID);
CREATE OR REPLACE FUNCTION get_user_profile_by_id(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  first_name VARCHAR,
  last_name VARCHAR,
  email VARCHAR,
  phone VARCHAR,
  user_type_id INTEGER,
  email_verified BOOLEAN,
  is_active BOOLEAN
)
LANGUAGE sql
STABLE
AS $$
  SELECT u.id, u.first_name, u.last_name, u.email, u.phone,
    u.user_type_id, u.email_verified, u.is_active

  FROM users u
  WHERE u.id = p_user_id AND u.is_active = TRUE
  LIMIT 1;
$$;
COMMIT;
