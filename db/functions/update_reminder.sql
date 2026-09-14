CREATE OR REPLACE FUNCTION update_reminder(p_reminder_id UUID, p_payload JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE reminders SET
    name = p_payload->>'name',
    description = NULLIF(p_payload->>'description', ''),
    is_active = (p_payload->>'isActive')::BOOLEAN,
    date = (p_payload->>'date')::TIMESTAMPTZ,
    urgency_id = (p_payload->>'urgency')::INTEGER
  WHERE id = p_reminder_id;

  IF NOT FOUND THEN RETURN FALSE; END IF;

  DELETE FROM reminder_proposals WHERE reminder_id = p_reminder_id;

  IF jsonb_typeof(p_payload->'reservation') = 'array' THEN
    INSERT INTO reminder_proposals (reminder_id, proposal_id, position)
    SELECT p_reminder_id, value::TEXT::UUID, ordinality - 1
    FROM jsonb_array_elements_text(p_payload->'reservation') WITH ORDINALITY;
  END IF;

  RETURN TRUE;
END;
$$;
