CREATE OR REPLACE FUNCTION get_user_by_id_with_proposals(p_user_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', u.id,
    'first_name', u.first_name,
    'last_name', u.last_name,
    'email', u.email,
    'phone', u.phone,
    'user_type_id', u.user_type_id,
    'email_verified', u.email_verified,
    'is_active', u.is_active,
    'last_login_at', u.last_login_at,
    'created_at', u.created_at,
    'updated_at', u.updated_at,
    'courses', COALESCE((
    SELECT jsonb_agg(jsonb_build_object(
      'id', course.id,
      'title', course.title,
      'description', course.description,
      'image', course.image
    ) ORDER BY course.title, course.id)
    FROM courses course
    WHERE course.is_active = TRUE
      AND EXISTS (
      SELECT 1
      FROM course_product_links course_product
      JOIN proposal_products proposal_product
        ON proposal_product.product_id = course_product.product_id
      JOIN proposals proposal ON proposal.id = proposal_product.proposal_id
      JOIN proposal_users proposal_user ON proposal_user.proposal_id = proposal.id
      LEFT JOIN catalog status ON status.id = proposal.status_id
      WHERE course_product.course_id = course.id
        AND proposal_user.user_id = p_user_id
        AND (
          proposal.parent_id IS NOT NULL
          OR COALESCE(LOWER(TRIM(status.label)) IN ('reservado', 'terminado'), FALSE)
          OR EXISTS (
            SELECT 1 FROM payments payment
            WHERE payment.proposal_id = proposal.id AND payment.payment <> 0
          )
        )
    )
  ), '[]'::jsonb),
    'proposals', COALESCE((
      SELECT jsonb_agg(get_proposal_by_id(p.id, FALSE, TRUE) ORDER BY p.created_at DESC)
      FROM proposal_users pu
      JOIN proposals p ON p.id = pu.proposal_id
      WHERE pu.user_id = u.id
    ), '[]'::JSONB)
  )
  FROM users u
  WHERE u.id = p_user_id;
$$;
