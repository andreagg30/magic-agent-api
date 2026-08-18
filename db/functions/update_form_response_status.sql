CREATE OR REPLACE FUNCTION update_form_response_status(
  p_response_id UUID,
  p_status_id INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM catalog
    WHERE id = p_status_id
      AND category_code = 'form_response_status'
      AND is_active = TRUE
  ) THEN
    RAISE EXCEPTION 'InvalidFormResponseStatus' USING ERRCODE = '22023';
  END IF;

  UPDATE form_responses
  SET status_id = p_status_id
  WHERE id = p_response_id;

  RETURN FOUND;
END;
$$;
