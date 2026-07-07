CREATE OR REPLACE FUNCTION verify_user_email_with_code(
    p_user_id UUID,
    p_code_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE users
    SET
        email_verified = TRUE,
        updated_at = NOW()
    WHERE id = p_user_id;

    UPDATE user_verification_codes
    SET used_at = NOW()
    WHERE id = p_code_id
      AND user_id = p_user_id
      AND used_at IS NULL;
END;
$$;