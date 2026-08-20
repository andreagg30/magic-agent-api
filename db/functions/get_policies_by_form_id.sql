CREATE OR REPLACE FUNCTION get_policies_by_form_id(p_form_id UUID)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_policy_by_id(p.id)
  FROM policy_forms pf
  JOIN policies p ON p.id = pf.policy_id
  WHERE pf.form_id = p_form_id
  ORDER BY p.created_at DESC;
$$;
