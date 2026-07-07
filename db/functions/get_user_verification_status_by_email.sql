CREATE OR REPLACE FUNCTION get_user_verification_status_by_email(
    p_email VARCHAR
)
RETURNS TABLE (
    id UUID,
    email_verified BOOLEAN
)
LANGUAGE sql
AS $$
    SELECT
        u.id,
        u.email_verified
    FROM users u
    WHERE LOWER(u.email) = LOWER(TRIM(p_email))
    LIMIT 1;
$$;