-- GET USER BY LOGIN

CREATE OR REPLACE FUNCTION get_user_for_login(
    p_email VARCHAR
)
RETURNS TABLE (
    id UUID,
    first_name VARCHAR,
    last_name VARCHAR,
    email VARCHAR,
    password_hash TEXT,
    user_type_id INTEGER,
    email_verified BOOLEAN,
    is_active BOOLEAN
)
LANGUAGE sql
AS $$
    SELECT
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        u.password_hash,
        u.user_type_id,
        u.email_verified,
        u.is_active
    FROM users u
    WHERE LOWER(u.email) = LOWER(TRIM(p_email))
    LIMIT 1;
$$;