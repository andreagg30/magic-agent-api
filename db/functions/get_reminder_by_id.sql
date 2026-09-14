CREATE OR REPLACE FUNCTION get_reminder_by_id(p_reminder_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', r.id,
    'name', r.name,
    'description', r.description,
    'isActive', r.is_active,
    'date', r.date,
    'urgencyId', r.urgency_id,
    'urgency', jsonb_build_object('label', c.label, 'value', c.id),
    'reservations', COALESCE((
      SELECT jsonb_agg(
        get_proposal_by_id(rp.proposal_id, FALSE)
        ORDER BY rp.position
      )
      FROM reminder_proposals rp
      WHERE rp.reminder_id = r.id
    ), '[]'::JSONB),
    'createdAt', r.created_at,
    'updatedAt', r.updated_at
  )
  FROM reminders r
  JOIN catalog c ON c.id = r.urgency_id
  WHERE r.id = p_reminder_id;
$$;
