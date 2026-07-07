CREATE OR REPLACE FUNCTION update_user_email(
    p_user_id UUID,
    p_email VARCHAR
)
RETURNS VOID
LANGUAGE sql
AS $$
    UPDATE users
    SET
        email = LOWER(TRIM(p_email)),
        email_verified = FALSE,
        updated_at = NOW()
    WHERE id = p_user_id;
$$;