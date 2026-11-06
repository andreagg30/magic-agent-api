CREATE OR REPLACE FUNCTION select_proposal(p_proposal_id UUID, p_payload JSONB)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_proposal proposals%ROWTYPE;
  v_option JSONB;
  v_products JSONB := '[]'::JSONB;
  v_total NUMERIC;
BEGIN
  SELECT * INTO v_proposal FROM proposals WHERE id = p_proposal_id FOR UPDATE;
  IF NOT FOUND THEN RETURN FALSE; END IF;

  IF p_payload->'selectedVariation' = 'null'::JSONB THEN
    v_total := COALESCE(v_proposal.total, 0);
  ELSE
    v_products := COALESCE(NULLIF(p_payload->'selectedVariation'->'products', 'null'::JSONB), '[]'::JSONB);
    v_total := COALESCE((p_payload->'selectedVariation'->>'total')::NUMERIC, 0);
    DELETE FROM proposal_products WHERE proposal_id = p_proposal_id;
  END IF;

  FOR v_option IN SELECT value FROM jsonb_array_elements(p_payload->'selectedExtras') LOOP
    v_products := v_products || COALESCE(NULLIF(v_option->'products', 'null'::JSONB), '[]'::JSONB);
    v_total := v_total + COALESCE((v_option->>'total')::NUMERIC, 0);
  END LOOP;

  INSERT INTO proposal_products (
    proposal_id, product_id, add_additional_info, from_date, to_date,
    date, new_party, show_notes, notes, position
  )
  SELECT p_proposal_id,
    COALESCE(NULLIF(item->>'productId', ''), item->'product'->>'id')::UUID,
    (item->>'addAdditionalInfo')::BOOLEAN,
    NULLIF(item->>'fromDate', '')::DATE, NULLIF(item->>'toDate', '')::DATE,
    NULLIF(item->>'date', '')::DATE, FALSE, (item->>'showNotes')::BOOLEAN,
    item->>'notes',
    (SELECT COALESCE(MAX(position) + 1, 0) FROM proposal_products WHERE proposal_id = p_proposal_id) + ordinality - 1
  FROM jsonb_array_elements(v_products) WITH ORDINALITY AS entries(item, ordinality);

  DELETE FROM proposal_party_members WHERE proposal_id = p_proposal_id;
  INSERT INTO proposal_party_members (proposal_id, user_id, last_name, name, dob, position)
  SELECT p_proposal_id, NULLIF(member->>'userId', '')::UUID,
    member->>'lastName', member->>'name', NULLIF(member->>'dob', '')::DATE,
    ordinality - 1
  FROM jsonb_array_elements(p_payload->'party') WITH ORDINALITY AS entries(member, ordinality);

  DELETE FROM proposal_options WHERE proposal_id = p_proposal_id;
  UPDATE proposals SET
    billing_country_value = p_payload->'billingAddress'->'country'->>'value',
    billing_country_label = p_payload->'billingAddress'->'country'->>'label',
    billing_line1 = p_payload->'billingAddress'->>'line1',
    billing_line2 = p_payload->'billingAddress'->>'line2',
    billing_city = p_payload->'billingAddress'->>'city',
    billing_state = p_payload->'billingAddress'->>'state',
    billing_zip = p_payload->'billingAddress'->>'zip',
    billing_phone = p_payload->'billingAddress'->>'phone',
    total = CASE WHEN total IS DISTINCT FROM v_total THEN v_total ELSE total END,
    status_id = 35,
    add_extras = FALSE,
    add_variations = FALSE
  WHERE id = p_proposal_id;
  RETURN TRUE;
END;
$$;
