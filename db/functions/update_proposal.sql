CREATE OR REPLACE FUNCTION update_proposal(p_proposal_id UUID, p_payload JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_product_id UUID;
  v_item JSONB;
  v_position INTEGER;
BEGIN
  UPDATE proposals SET
    parent_id = NULLIF(p_payload->>'parentId', '')::UUID,
    response_id = NULLIF(p_payload->>'responseId', '')::UUID,
    name = NULLIF(p_payload->>'name', ''),
    description = NULLIF(p_payload->>'description', ''),
    total = NULLIF(p_payload->>'total', '')::NUMERIC(14, 2),
    total_type_id = NULLIF(p_payload->>'totalType', '')::INTEGER,
    status_id = NULLIF(p_payload->>'statusId', '')::INTEGER,
    is_active = (p_payload->>'isActive')::BOOLEAN,
    is_package = NULLIF(p_payload->>'isPackage', '')::BOOLEAN,
    show_main_page = NULLIF(p_payload->>'showMainPage', '')::BOOLEAN,
    show_party = NULLIF(p_payload->>'showParty', '')::BOOLEAN,
    notes = NULLIF(p_payload->>'notes', ''),
    gral_party_number = NULLIF(p_payload->>'gralPartyNumber', '')::INTEGER,
    gral_party_children = NULLIF(p_payload->>'gralPartyChildren', '')::INTEGER
  WHERE id = p_proposal_id;

  IF NOT FOUND THEN RETURN FALSE; END IF;

  DELETE FROM proposal_images WHERE proposal_id = p_proposal_id;
  DELETE FROM proposal_party_members WHERE proposal_id = p_proposal_id;
  DELETE FROM proposal_products WHERE proposal_id = p_proposal_id;
  DELETE FROM proposal_users WHERE proposal_id = p_proposal_id;

  IF jsonb_typeof(p_payload->'images') = 'array' THEN
    INSERT INTO proposal_images (proposal_id, src, name, position)
    SELECT
      p_proposal_id,
      NULLIF(image->>'src', ''),
      NULLIF(image->>'name', ''),
      ordinality - 1
    FROM jsonb_array_elements(p_payload->'images') WITH ORDINALITY AS entries(image, ordinality)
    WHERE NULLIF(image->>'src', '') IS NOT NULL;
  END IF;

  IF jsonb_typeof(p_payload->'users') = 'array' THEN
    INSERT INTO proposal_users (proposal_id, user_id, position)
    SELECT p_proposal_id, value::TEXT::UUID, ordinality - 1
    FROM jsonb_array_elements_text(p_payload->'users') WITH ORDINALITY;
  END IF;

  IF jsonb_typeof(p_payload->'products') = 'array' THEN
    v_position := 0;
    FOR v_item IN SELECT value FROM jsonb_array_elements(p_payload->'products') LOOP
      INSERT INTO proposal_products (
        proposal_id, product_id, add_additional_info, from_date, to_date,
        date, new_party, show_notes, notes, position
      ) VALUES (
        p_proposal_id,
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
          p_proposal_id, v_product_id, NULLIF(member->>'userId', '')::UUID,
          NULLIF(member->>'lastName', ''), NULLIF(member->>'name', ''),
          NULLIF(member->>'dob', '')::DATE, ordinality - 1
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
      p_proposal_id, NULL, NULLIF(member->>'userId', '')::UUID,
      NULLIF(member->>'lastName', ''), NULLIF(member->>'name', ''),
      NULLIF(member->>'dob', '')::DATE, ordinality - 1
    FROM jsonb_array_elements(p_payload->'party') WITH ORDINALITY AS entries(member, ordinality);
  END IF;

  PERFORM sync_proposal_reminders(p_proposal_id, p_payload->'reminders');
  PERFORM sync_proposal_payments(p_proposal_id, p_payload->'payments');

  RETURN TRUE;
END;
$$;
