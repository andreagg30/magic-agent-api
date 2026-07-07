CREATE OR REPLACE FUNCTION add_user_verification_code(
    p_user_id UUID,
    p_code_hash TEXT,
    p_expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '10 minutes'
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code_id UUID;
BEGIN
    UPDATE user_verification_codes
    SET used_at = NOW()
    WHERE user_id = p_user_id
      AND used_at IS NULL;

    INSERT INTO user_verification_codes (
        user_id,
        code_hash,
        expires_at
    )
    VALUES (
        p_user_id,
        p_code_hash,
        p_expires_at
    )
    RETURNING id INTO v_code_id;

    RETURN v_code_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El user_id % no existe en users', p_user_id;
END;
$$;