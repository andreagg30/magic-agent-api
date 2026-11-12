-- Return the selected proposal ID, which may be a newly created package copy.
BEGIN;
DROP FUNCTION IF EXISTS select_proposal(UUID, JSONB);
CREATE OR REPLACE FUNCTION select_proposal(p_proposal_id UUID, p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_proposal proposals%ROWTYPE;
  v_option JSONB;
  v_target_id UUID := p_proposal_id;
  v_clone JSONB;
  v_products JSONB := '[]'::JSONB;
  v_total NUMERIC;
BEGIN
  SELECT * INTO v_proposal FROM proposals WHERE id = p_proposal_id FOR UPDATE;
  IF NOT FOUND THEN RETURN NULL; END IF;

  IF v_proposal.is_package IS TRUE THEN
    -- Normalize the read response into the existing creation payload.
    -- Related records receive fresh IDs so nothing in the package is updated.
    v_clone := get_proposal_by_id(p_proposal_id, FALSE, TRUE);
    v_clone := v_clone || jsonb_build_object(
      'parentId', p_proposal_id,
      'isPackage', FALSE,
      'style', v_proposal.style_id,
      'totalType', v_proposal.total_type_id,
      'users', COALESCE((
        SELECT jsonb_agg(user_id ORDER BY position)
        FROM proposal_users WHERE proposal_id = p_proposal_id
      ), '[]'::JSONB),
      'reminders', COALESCE((
        SELECT jsonb_agg((item - 'id') || jsonb_build_object('urgency', item->'urgencyId') ORDER BY position)
        FROM jsonb_array_elements(v_clone->'reminders') WITH ORDINALITY AS r(item, position)
      ), '[]'::JSONB),
      'payments', COALESCE((
        SELECT jsonb_agg(item - 'id' ORDER BY position)
        FROM jsonb_array_elements(v_clone->'payments') WITH ORDINALITY AS pay(item, position)
      ), '[]'::JSONB)
    );
    v_target_id := add_proposal(v_clone);
  END IF;

  IF p_payload->'selectedVariation' = 'null'::JSONB THEN
    v_total := COALESCE(v_proposal.total, 0);
  ELSE
    v_products := COALESCE(NULLIF(p_payload->'selectedVariation'->'products', 'null'::JSONB), '[]'::JSONB);
    v_total := COALESCE((p_payload->'selectedVariation'->>'total')::NUMERIC, 0);
    DELETE FROM proposal_products WHERE proposal_id = v_target_id;
  END IF;

  FOR v_option IN SELECT value FROM jsonb_array_elements(p_payload->'selectedExtras') LOOP
    v_products := v_products || COALESCE(NULLIF(v_option->'products', 'null'::JSONB), '[]'::JSONB);
    v_total := v_total + COALESCE((v_option->>'total')::NUMERIC, 0);
  END LOOP;

  INSERT INTO proposal_products (
    proposal_id, product_id, add_additional_info, from_date, to_date,
    date, new_party, show_notes, notes, position
  )
  SELECT v_target_id,
    COALESCE(NULLIF(item->>'productId', ''), item->'product'->>'id')::UUID,
    (item->>'addAdditionalInfo')::BOOLEAN,
    NULLIF(item->>'fromDate', '')::DATE, NULLIF(item->>'toDate', '')::DATE,
    NULLIF(item->>'date', '')::DATE, FALSE, (item->>'showNotes')::BOOLEAN,
    item->>'notes',
    (SELECT COALESCE(MAX(position) + 1, 0) FROM proposal_products WHERE proposal_id = v_target_id) + ordinality - 1
  FROM jsonb_array_elements(v_products) WITH ORDINALITY AS entries(item, ordinality);

  DELETE FROM proposal_party_members WHERE proposal_id = v_target_id;
  INSERT INTO proposal_party_members (proposal_id, user_id, last_name, name, dob, position)
  SELECT v_target_id, NULLIF(member->>'userId', '')::UUID,
    member->>'lastName', member->>'name', NULLIF(member->>'dob', '')::DATE,
    ordinality - 1
  FROM jsonb_array_elements(p_payload->'party') WITH ORDINALITY AS entries(member, ordinality);

  DELETE FROM proposal_options WHERE proposal_id = v_target_id;
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
  WHERE id = v_target_id;
  RETURN v_target_id;
END;
$$;

COMMIT;
