CREATE OR REPLACE FUNCTION sync_proposal_options(p_proposal_id UUID, p_payload JSONB)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
  v_kind TEXT;
  v_entry JSONB;
  v_option_id UUID;
  v_position INTEGER;
BEGIN
  UPDATE proposals SET
    add_extras = COALESCE((p_payload->>'addExtras')::BOOLEAN, add_extras),
    add_variations = COALESCE((p_payload->>'addVariations')::BOOLEAN, add_variations)
  WHERE id = p_proposal_id;
  FOREACH v_kind IN ARRAY ARRAY['extras', 'variations'] LOOP
    -- Omitted arrays preserve existing options; [] explicitly clears them.
    IF NOT p_payload ? v_kind THEN CONTINUE; END IF;
    DELETE FROM proposal_options WHERE proposal_id = p_proposal_id AND kind = v_kind;
    v_position := 0;
    FOR v_entry IN SELECT value FROM jsonb_array_elements(p_payload->v_kind) LOOP
      INSERT INTO proposal_options(proposal_id, kind, description, total, position)
      VALUES (p_proposal_id, v_kind, v_entry->>'description', NULLIF(v_entry->>'total', '')::NUMERIC(14,2), v_position)
      RETURNING id INTO v_option_id;
      INSERT INTO proposal_option_products(option_id, product_id, add_additional_info, from_date, to_date, date, show_notes, notes, position)
      SELECT v_option_id,
        COALESCE(NULLIF(item->>'productId', ''), item->'product'->>'id')::UUID,
        (item->>'addAdditionalInfo')::BOOLEAN,
        NULLIF(item->>'fromDate', '')::DATE, NULLIF(item->>'toDate', '')::DATE,
        NULLIF(item->>'date', '')::DATE, (item->>'showNotes')::BOOLEAN,
        item->>'notes', ordinality - 1
      FROM jsonb_array_elements(COALESCE(v_entry->'products', '[]'::JSONB)) WITH ORDINALITY AS entries(item, ordinality);
      v_position := v_position + 1;
    END LOOP;
  END LOOP;
END;
$$;
