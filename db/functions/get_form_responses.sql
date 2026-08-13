CREATE OR REPLACE FUNCTION get_form_responses(p_form_id UUID DEFAULT NULL)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', r.id,
    'formId', r.form_id,
    'formName', f.name,
    'statusId', r.status_id,
    'status', jsonb_build_object('id', c.id, 'label', c.label),
    --'sections', r.payload,
    'createdAt', r.created_at
  )
  FROM form_responses r
  JOIN forms f ON f.id = r.form_id
  JOIN catalog c ON c.id = r.status_id
  WHERE p_form_id IS NULL OR r.form_id = p_form_id
  ORDER BY r.created_at DESC;
$$;
