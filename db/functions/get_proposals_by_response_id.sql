CREATE OR REPLACE FUNCTION get_proposals_by_response_id(p_response_id UUID)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_proposal_by_id(p.id)
  FROM proposals p
  WHERE p.response_id = p_response_id
  ORDER BY p.created_at DESC;
$$;
