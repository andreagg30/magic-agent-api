CREATE OR REPLACE FUNCTION get_proposals(
  p_is_package BOOLEAN DEFAULT NULL,
  p_parent_id UUID DEFAULT NULL
)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_proposal_by_id(p.id, FALSE, FALSE)
  FROM proposals p
  WHERE (p_is_package IS NULL OR p.is_package = p_is_package)
    AND (p_parent_id IS NULL OR p.parent_id = p_parent_id)
  ORDER BY p.created_at DESC;
$$;
