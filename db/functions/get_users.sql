CREATE OR REPLACE FUNCTION get_users()
RETURNS TABLE (
  id UUID,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(20),
  user_type_id INTEGER,
  email_verified BOOLEAN,
  is_active BOOLEAN,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    u.id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone,
    u.user_type_id,
    u.email_verified,
    u.is_active,
    u.last_login_at,
    u.created_at,
    u.updated_at
  FROM users u
  ORDER BY u.created_at DESC;
$$;
