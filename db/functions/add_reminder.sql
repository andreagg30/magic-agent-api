CREATE OR REPLACE FUNCTION add_reminder(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_reminder_id UUID;
BEGIN
  INSERT INTO reminders (
    name, description, is_active, date, urgency_id
  ) VALUES (
    p_payload->>'name',
    NULLIF(p_payload->>'description', ''),
    (p_payload->>'isActive')::BOOLEAN,
    (p_payload->>'date')::TIMESTAMPTZ,
    (p_payload->>'urgency')::INTEGER
  )
  RETURNING id INTO v_reminder_id;

  IF jsonb_typeof(p_payload->'reservation') = 'array' THEN
    INSERT INTO reminder_proposals (reminder_id, proposal_id, position)
    SELECT v_reminder_id, value::TEXT::UUID, ordinality - 1
    FROM jsonb_array_elements_text(p_payload->'reservation') WITH ORDINALITY;
  END IF;

  RETURN v_reminder_id;
END;
$$;
