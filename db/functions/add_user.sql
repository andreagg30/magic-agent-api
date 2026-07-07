
CREATE OR REPLACE FUNCTION add_user(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_password_hash TEXT,
    p_user_type_id INTEGER
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    INSERT INTO users (
        first_name,
        last_name,
        email,
        phone,
        password_hash,
        user_type_id
    )
    VALUES (
        p_first_name,
        p_last_name,
        LOWER(TRIM(p_email)),
        p_phone,
        p_password_hash,
        p_user_type_id
    )
    RETURNING id INTO v_user_id;

    RETURN v_user_id;
END;
$$;