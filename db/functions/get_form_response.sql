CREATE OR REPLACE FUNCTION get_form_response
(p_response_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
SELECT jsonb_build_object(
    'id', r.id,
    'formId', r.form_id,
    'formName', f.name,
    'statusId', r.status_id,
    'status', jsonb_build_object('id', c.id, 'label', c.label),
    'sections', r.payload,
    'createdAt', r.created_at
  )
FROM form_responses r
  JOIN catalog c ON c.id = r.status_id
  JOIN forms f ON f.id = r.form_id
WHERE r.id = p_response_id;
$$;
