CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token_hash TEXT NOT NULL,
  user_agent TEXT,
  ip_address TEXT,
  expires_at TIMESTAMP NOT NULL,
  revoked_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION add_user_session(
    p_user_id UUID,
    p_refresh_token_hash TEXT,
    p_user_agent TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL,
    p_expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '7 days'
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_session_id UUID;
BEGIN
    INSERT INTO user_sessions (
        user_id,
        refresh_token_hash,
        user_agent,
        ip_address,
        expires_at
    )
    VALUES (
        p_user_id,
        p_refresh_token_hash,
        NULLIF(TRIM(p_user_agent), ''),
        NULLIF(TRIM(p_ip_address), ''),
        p_expires_at
    )
    RETURNING id INTO v_session_id;

    RETURN v_session_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El user_id % no existe en users', p_user_id;
END;
$$;

-- GET SESSION BY TOEN AND ID
CREATE OR REPLACE FUNCTION get_session_by_token_and_id(
    p_refresh_token_hash TEXT,
    p_user_id UUID
)
RETURNS user_sessions
LANGUAGE sql
AS $$
    SELECT * FROM user_sessions
      WHERE refresh_token_hash = p_refresh_token_hash
        AND user_id = p_user_id
    LIMIT 1
$$;

-- UPDATE SESSION REVOKED AT
CREATE OR REPLACE FUNCTION revoke_session(
    p_session_id UUID
)
RETURNS VOID
LANGUAGE sql
AS $$
    UPDATE user_sessions
    SET revoked_at = NOW()
    WHERE id = p_session_id
$$;

-- DELETE EXPIRED SESSIONS
CREATE OR REPLACE FUNCTION revoke_session_by_token_hash(
    p_refresh_token_hash TEXT
)
RETURNS VOID
LANGUAGE sql
AS $$
    UPDATE user_sessions
    SET revoked_at = NOW()
    WHERE refresh_token_hash = p_refresh_token_hash
      AND revoked_at IS NULL;
$$;