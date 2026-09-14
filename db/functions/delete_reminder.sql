CREATE OR REPLACE FUNCTION delete_reminder(p_reminder_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM reminders WHERE id = p_reminder_id;
  RETURN FOUND;
END;
$$;
