CREATE OR REPLACE FUNCTION sync_proposal_reminders(
  p_proposal_id UUID,
  p_reminders JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_item JSONB;
  v_reminder_id UUID;
  v_position INTEGER := 0;
  v_keep_ids UUID[] := ARRAY[]::UUID[];
  v_removed_ids UUID[] := ARRAY[]::UUID[];
BEGIN
  IF jsonb_typeof(p_reminders) = 'array' THEN
    FOR v_item IN SELECT value FROM jsonb_array_elements(p_reminders) LOOP
      v_reminder_id := NULLIF(v_item->>'id', '')::UUID;

      IF v_reminder_id IS NULL THEN
        INSERT INTO reminders (
          name, description, is_active, date, urgency_id
        ) VALUES (
          v_item->>'name',
          NULLIF(v_item->>'description', ''),
          (v_item->>'isActive')::BOOLEAN,
          (v_item->>'date')::TIMESTAMPTZ,
          (v_item->>'urgency')::INTEGER
        ) RETURNING id INTO v_reminder_id;
      ELSE
        UPDATE reminders SET
          name = v_item->>'name',
          description = NULLIF(v_item->>'description', ''),
          is_active = (v_item->>'isActive')::BOOLEAN,
          date = (v_item->>'date')::TIMESTAMPTZ,
          urgency_id = (v_item->>'urgency')::INTEGER
        WHERE id = v_reminder_id;

        IF NOT FOUND THEN
          RAISE EXCEPTION 'InvalidReminderId' USING ERRCODE = '23503';
        END IF;
      END IF;

      INSERT INTO reminder_proposals (reminder_id, proposal_id, position)
      VALUES (v_reminder_id, p_proposal_id, v_position)
      ON CONFLICT (reminder_id, proposal_id)
      DO UPDATE SET position = EXCLUDED.position;

      v_keep_ids := array_append(v_keep_ids, v_reminder_id);
      v_position := v_position + 1;
    END LOOP;
  END IF;

  SELECT COALESCE(array_agg(reminder_id), ARRAY[]::UUID[])
  INTO v_removed_ids
  FROM reminder_proposals
  WHERE proposal_id = p_proposal_id
    AND NOT (reminder_id = ANY(v_keep_ids));

  DELETE FROM reminder_proposals
  WHERE proposal_id = p_proposal_id
    AND NOT (reminder_id = ANY(v_keep_ids));

  DELETE FROM reminders r
  WHERE r.id = ANY(v_removed_ids)
    AND NOT EXISTS (
      SELECT 1 FROM reminder_proposals rp WHERE rp.reminder_id = r.id
    );
END;
$$;
