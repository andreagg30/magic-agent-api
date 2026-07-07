CREATE OR REPLACE FUNCTION get_password_reset_code_by_user_and_hash(
    p_user_id UUID,
    p_code_hash TEXT
)
RETURNS TABLE (
    id UUID,
    expires_at TIMESTAMP,
    used_at TIMESTAMP
)
LANGUAGE sql
AS $$
    SELECT
        prc.id,
        prc.expires_at,
        prc.used_at
    FROM password_reset_codes prc
    WHERE prc.user_id = p_user_id
      AND prc.code_hash = p_code_hash
    ORDER BY prc.created_at DESC
    LIMIT 1;
$$;