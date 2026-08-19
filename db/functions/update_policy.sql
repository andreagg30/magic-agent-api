CREATE OR REPLACE FUNCTION update_policy(
  p_policy_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_is_active BOOLEAN,
  p_show_footer BOOLEAN,
  p_show_wp_description BOOLEAN,
  p_wp_description TEXT,
  p_form_ids UUID[]
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  IF char_length(p_description) > 3600 THEN
    RAISE EXCEPTION 'PolicyDescriptionTooLong' USING ERRCODE = '22001';
  END IF;

  UPDATE policies
  SET
    title = TRIM(p_title),
    description = p_description,
    is_active = p_is_active,
    show_footer = p_show_footer,
    show_wp_description = p_show_wp_description,
    wp_description = NULLIF(p_wp_description, '')
  WHERE id = p_policy_id;

  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  DELETE FROM policy_forms WHERE policy_id = p_policy_id;

  INSERT INTO policy_forms (policy_id, form_id, position)
  SELECT p_policy_id, form_id, ordinal_position - 1
  FROM unnest(COALESCE(p_form_ids, ARRAY[]::UUID[]))
    WITH ORDINALITY AS form_ids(form_id, ordinal_position);

  RETURN TRUE;
END;
$$;
