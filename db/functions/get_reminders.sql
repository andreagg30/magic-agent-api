CREATE OR REPLACE FUNCTION get_reminders()
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_reminder_by_id(r.id)
  FROM reminders r
  ORDER BY r.date ASC, r.created_at DESC;
$$;
