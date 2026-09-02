CREATE OR REPLACE FUNCTION delete_proposal(p_proposal_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM proposals WHERE id = p_proposal_id;
  RETURN FOUND;
END;
$$;
