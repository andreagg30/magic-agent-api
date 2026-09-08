CREATE OR REPLACE FUNCTION get_proposals(p_is_package BOOLEAN DEFAULT NULL)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_proposal_by_id(p.id)
  FROM proposals p
  WHERE p_is_package IS NULL OR p.is_package = p_is_package
  ORDER BY p.created_at DESC;
$$;
