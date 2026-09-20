CREATE OR REPLACE FUNCTION get_proposals(
  p_is_package BOOLEAN DEFAULT NULL,
  p_parent_id UUID DEFAULT NULL,
  p_is_reservation BOOLEAN DEFAULT NULL
)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT (get_proposal_by_id(p.id, FALSE, FALSE) - 'payments')
    || jsonb_build_object('totalPayment', COALESCE((
      SELECT SUM(pay.payment)
      FROM payments pay
      WHERE pay.proposal_id = p.id
    ), 0))
  FROM proposals p
  LEFT JOIN catalog status_catalog ON status_catalog.id = p.status_id
  WHERE (p_is_package IS NULL OR p.is_package = p_is_package)
    AND (p_parent_id IS NULL OR p.parent_id = p_parent_id)
    AND (
      p_is_reservation IS NULL
      OR p_is_reservation = (
        p.parent_id IS NOT NULL
        OR COALESCE(
          LOWER(TRIM(status_catalog.label)) IN ('reservado', 'terminado'),
          FALSE
        )
        OR EXISTS (
          SELECT 1
          FROM payments pay
          WHERE pay.proposal_id = p.id
            AND pay.payment <> 0
        )
      )
    )
  ORDER BY p.created_at DESC;
$$;
