CREATE OR REPLACE FUNCTION get_proposals()
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_proposal_by_id(p.id)
  FROM proposals p
  ORDER BY p.created_at DESC;
$$;
