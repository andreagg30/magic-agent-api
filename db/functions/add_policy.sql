CREATE OR REPLACE FUNCTION add_policy(
  p_title TEXT,
  p_description TEXT,
  p_is_active BOOLEAN,
  p_show_footer BOOLEAN,
  p_show_wp_description BOOLEAN,
  p_wp_description TEXT,
  p_form_ids UUID[]
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_policy_id UUID;
BEGIN
  IF char_length(p_description) > 3600 THEN
    RAISE EXCEPTION 'PolicyDescriptionTooLong' USING ERRCODE = '22001';
  END IF;

  INSERT INTO policies (
    title,
    description,
    is_active,
    show_footer,
    show_wp_description,
    wp_description
  ) VALUES (
    TRIM(p_title),
    p_description,
    COALESCE(p_is_active, TRUE),
    COALESCE(p_show_footer, FALSE),
    COALESCE(p_show_wp_description, FALSE),
    NULLIF(p_wp_description, '')
  )
  RETURNING id INTO v_policy_id;

  INSERT INTO policy_forms (policy_id, form_id, position)
  SELECT v_policy_id, form_id, ordinal_position - 1
  FROM unnest(COALESCE(p_form_ids, ARRAY[]::UUID[]))
    WITH ORDINALITY AS form_ids(form_id, ordinal_position);

  RETURN v_policy_id;
END;
$$;
