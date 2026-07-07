CREATE OR REPLACE FUNCTION reset_user_password(
    p_user_id UUID,
    p_reset_code_id UUID,
    p_password_hash TEXT
)
RETURNS VOID
LANGUAGE sql
AS $$
    UPDATE users
    SET
        password_hash = p_password_hash,
        updated_at = NOW()
    WHERE id = p_user_id;

    UPDATE password_reset_codes
    SET used_at = NOW()
    WHERE id = p_reset_code_id
      AND user_id = p_user_id
      AND used_at IS NULL;

    UPDATE user_sessions
    SET revoked_at = NOW()
    WHERE user_id = p_user_id
      AND revoked_at IS NULL;
$$;