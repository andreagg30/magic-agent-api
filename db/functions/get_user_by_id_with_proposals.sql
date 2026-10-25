CREATE OR REPLACE FUNCTION get_user_by_id_with_proposals(p_user_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', u.id,
    'first_name', u.first_name,
    'last_name', u.last_name,
    'email', u.email,
    'phone', u.phone,
    'user_type_id', u.user_type_id,
    'email_verified', u.email_verified,
    'is_active', u.is_active,
    'last_login_at', u.last_login_at,
    'created_at', u.created_at,
    'updated_at', u.updated_at,
    'proposals', COALESCE((
      SELECT jsonb_agg(get_proposal_by_id(p.id, FALSE, TRUE) ORDER BY p.created_at DESC)
      FROM proposal_users pu
      JOIN proposals p ON p.id = pu.proposal_id
      WHERE pu.user_id = u.id
    ), '[]'::JSONB)
  )
  FROM users u
  WHERE u.id = p_user_id;
$$;
