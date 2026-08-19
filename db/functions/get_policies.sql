CREATE OR REPLACE FUNCTION get_policies()
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_policy_by_id(p.id)
  FROM policies p
  ORDER BY p.created_at DESC;
$$;
