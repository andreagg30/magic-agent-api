CREATE OR REPLACE FUNCTION sync_proposal_payments(
  p_proposal_id UUID,
  p_payments JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_item JSONB;
  v_payment_id UUID;
  v_position INTEGER := 0;
  v_keep_ids UUID[] := ARRAY[]::UUID[];
BEGIN
  IF jsonb_typeof(p_payments) = 'array' THEN
    FOR v_item IN SELECT value FROM jsonb_array_elements(p_payments) LOOP
      v_payment_id := NULLIF(v_item->>'id', '')::UUID;

      IF v_payment_id IS NULL THEN
        INSERT INTO payments (proposal_id, notes, payment, date, position)
        VALUES (
          p_proposal_id,
          NULLIF(v_item->>'notes', ''),
          v_item->>'payment',
          (v_item->>'date')::TIMESTAMPTZ,
          v_position
        ) RETURNING id INTO v_payment_id;
      ELSE
        UPDATE payments SET
          notes = NULLIF(v_item->>'notes', ''),
          payment = v_item->>'payment',
          date = (v_item->>'date')::TIMESTAMPTZ,
          position = v_position
        WHERE id = v_payment_id
          AND proposal_id = p_proposal_id;

        IF NOT FOUND THEN
          RAISE EXCEPTION 'InvalidPaymentId' USING ERRCODE = '23503';
        END IF;
      END IF;

      v_keep_ids := array_append(v_keep_ids, v_payment_id);
      v_position := v_position + 1;
    END LOOP;
  END IF;

  DELETE FROM payments
  WHERE proposal_id = p_proposal_id
    AND NOT (id = ANY(v_keep_ids));
END;
$$;
