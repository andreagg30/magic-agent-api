CREATE OR REPLACE FUNCTION get_user_dashboard(p_user_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  WITH user_proposals AS (
    SELECT p.*,
      (p.status_id = 35 OR p.parent_id IS NOT NULL
        OR COALESCE(LOWER(TRIM(status.label)) IN ('reservado', 'terminado'), FALSE)
        OR EXISTS (
          SELECT 1 FROM payments payment
          WHERE payment.proposal_id = p.id AND payment.payment <> 0
        )) IS TRUE AS is_reservation
    FROM proposals p
    LEFT JOIN catalog status ON status.id = p.status_id
    WHERE p.is_package IS NOT TRUE
      AND EXISTS (
        SELECT 1 FROM proposal_users pu
        WHERE pu.proposal_id = p.id AND pu.user_id = p_user_id
      )
  )
  SELECT jsonb_build_object(
    'proposals', COALESCE((
      SELECT jsonb_agg(get_proposal_by_id(p.id, FALSE, TRUE) ORDER BY p.created_at DESC, p.id)
      FROM user_proposals p WHERE NOT p.is_reservation
    ), '[]'::JSONB),
    'reservations', COALESCE((
      SELECT jsonb_agg(get_proposal_by_id(p.id, FALSE, TRUE) ORDER BY p.created_at DESC, p.id)
      FROM user_proposals p WHERE p.is_reservation
    ), '[]'::JSONB),
    'courses', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', course.id, 'title', course.title,
        'description', course.description, 'image', course.image
      ) ORDER BY course.title, course.id)
      FROM courses course
      WHERE course.is_active = TRUE AND EXISTS (
        SELECT 1 FROM course_product_links link
        JOIN proposal_products product ON product.product_id = link.product_id
        JOIN user_proposals reservation ON reservation.id = product.proposal_id
        WHERE link.course_id = course.id AND reservation.is_reservation
      )
    ), '[]'::JSONB)
  )
  FROM users u WHERE u.id = p_user_id AND u.is_active = TRUE;
$$;
