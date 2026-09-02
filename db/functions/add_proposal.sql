CREATE OR REPLACE FUNCTION add_proposal(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_proposal_id UUID;
  v_product_id UUID;
  v_item JSONB;
  v_member JSONB;
  v_position INTEGER;
BEGIN
  INSERT INTO proposals (
    response_id, total, total_type_id, status_id, show_party, notes,
    gral_party_number, gral_party_children
  ) VALUES (
    NULLIF(p_payload->>'responseId', '')::UUID,
    NULLIF(p_payload->>'total', '')::NUMERIC(14, 2),
    NULLIF(p_payload->>'totalType', '')::INTEGER,
    NULLIF(p_payload->>'statusId', '')::INTEGER,
    NULLIF(p_payload->>'showParty', '')::BOOLEAN,
    NULLIF(p_payload->>'notes', ''),
    NULLIF(p_payload->>'gralPartyNumber', '')::INTEGER,
    NULLIF(p_payload->>'gralPartyChildren', '')::INTEGER
  ) RETURNING id INTO v_proposal_id;

  IF jsonb_typeof(p_payload->'users') = 'array' THEN
    INSERT INTO proposal_users (proposal_id, user_id, position)
    SELECT v_proposal_id, value::TEXT::UUID, ordinality - 1
    FROM jsonb_array_elements_text(p_payload->'users') WITH ORDINALITY;
  END IF;

  IF jsonb_typeof(p_payload->'products') = 'array' THEN
    v_position := 0;
    FOR v_item IN SELECT value FROM jsonb_array_elements(p_payload->'products') LOOP
      INSERT INTO proposal_products (
        proposal_id, product_id, add_additional_info, from_date, to_date,
        date, new_party, show_notes, notes, position
      ) VALUES (
        v_proposal_id,
        NULLIF(v_item->>'productId', '')::UUID,
        NULLIF(v_item->>'addAdditionalInfo', '')::BOOLEAN,
        NULLIF(v_item->>'fromDate', '')::DATE,
        NULLIF(v_item->>'toDate', '')::DATE,
        NULLIF(v_item->>'date', '')::DATE,
        NULLIF(v_item->>'newParty', '')::BOOLEAN,
        NULLIF(v_item->>'showNotes', '')::BOOLEAN,
        NULLIF(v_item->>'notes', ''),
        v_position
      ) RETURNING id INTO v_product_id;

      IF jsonb_typeof(v_item->'party') = 'array' THEN
        INSERT INTO proposal_party_members (
          proposal_id, proposal_product_id, user_id, last_name, name, dob, position
        )
        SELECT
          v_proposal_id,
          v_product_id,
          NULLIF(member->>'userId', '')::UUID,
          NULLIF(member->>'lastName', ''),
          NULLIF(member->>'name', ''),
          NULLIF(member->>'dob', '')::DATE,
          ordinality - 1
        FROM jsonb_array_elements(v_item->'party') WITH ORDINALITY AS entries(member, ordinality);
      END IF;
      v_position := v_position + 1;
    END LOOP;
  END IF;

  IF jsonb_typeof(p_payload->'party') = 'array' THEN
    INSERT INTO proposal_party_members (
      proposal_id, proposal_product_id, user_id, last_name, name, dob, position
    )
    SELECT
      v_proposal_id,
      NULL,
      NULLIF(member->>'userId', '')::UUID,
      NULLIF(member->>'lastName', ''),
      NULLIF(member->>'name', ''),
      NULLIF(member->>'dob', '')::DATE,
      ordinality - 1
    FROM jsonb_array_elements(p_payload->'party') WITH ORDINALITY AS entries(member, ordinality);
  END IF;

  RETURN v_proposal_id;
END;
$$;
