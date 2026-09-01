CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),

    password_hash TEXT NOT NULL,

    user_type_id INTEGER NOT NULL,

    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    last_login_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_users_user_type
        FOREIGN KEY (user_type_id)
        REFERENCES catalog(id)
);


/* CREATE UNIQUE INDEX users_email_lower_unique
ON users (LOWER(email));

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 */
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- CREATE USER

CREATE OR REPLACE FUNCTION add_user(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_password_hash TEXT,
    p_user_type_id INTEGER,
    p_email_verified BOOLEAN DEFAULT FALSE
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
        user_type_id,
        email_verified
    )
    VALUES (
        p_first_name,
        p_last_name,
        LOWER(TRIM(p_email)),
        p_phone,
        p_password_hash,
        p_user_type_id,
        p_email_verified
    )
    RETURNING id INTO v_user_id;

    RETURN v_user_id;
END;
$$;

-- GET USER BY EMAIL
CREATE OR REPLACE FUNCTION user_exists_by_email(
    p_email VARCHAR
)
RETURNS BOOLEAN
LANGUAGE sql
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM users u
        WHERE LOWER(u.email) = LOWER(TRIM(p_email))
    );
$$;



--- USER BY ID

CREATE OR REPLACE FUNCTION get_user_profile_by_id(
    p_user_id UUID
)
RETURNS TABLE (
    id UUID,
    first_name VARCHAR,
    last_name VARCHAR,
    email VARCHAR,
    phone VARCHAR,
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
        u.phone,
		u.user_type_id,
		u.email_verified,
		u.is_active
    FROM users u
    WHERE u.id = p_user_id
      AND u.is_active = TRUE
    LIMIT 1;
$$;
