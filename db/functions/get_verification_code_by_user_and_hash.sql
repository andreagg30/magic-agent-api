CREATE OR REPLACE FUNCTION get_verification_code_by_user_and_hash(
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
        uvc.id,
        uvc.expires_at,
        uvc.used_at
    FROM user_verification_codes uvc
    WHERE uvc.user_id = p_user_id
      AND uvc.code_hash = p_code_hash
    ORDER BY uvc.created_at DESC
    LIMIT 1;
$$;