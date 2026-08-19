CREATE OR REPLACE FUNCTION get_policy_by_id(p_policy_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', p.id,
    'title', p.title,
    'description', p.description,
    'isActive', p.is_active,
    'showFooter', p.show_footer,
    'showWpDescription', p.show_wp_description,
    'wpDescription', p.wp_description,
    'forms', COALESCE(
      (
        SELECT jsonb_agg(pf.form_id ORDER BY pf.position)
        FROM policy_forms pf
        WHERE pf.policy_id = p.id
      ),
      '[]'::jsonb
    ),
    'createdAt', p.created_at,
    'updatedAt', p.updated_at
  )
  FROM policies p
  WHERE p.id = p_policy_id;
$$;
