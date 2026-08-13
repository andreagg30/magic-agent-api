CREATE OR REPLACE FUNCTION delete_form_response(p_response_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM form_responses WHERE id = p_response_id;
  RETURN FOUND;
END;
$$;
