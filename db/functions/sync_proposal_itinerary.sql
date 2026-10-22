CREATE OR REPLACE FUNCTION sync_proposal_itinerary(
  p_proposal_id UUID,
  p_itinerary JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM proposal_itinerary_items
  WHERE proposal_id = p_proposal_id;

  IF jsonb_typeof(p_itinerary) = 'array' THEN
    INSERT INTO proposal_itinerary_items (
      proposal_id,
      name,
      description,
      reminder,
      date,
      position
    )
    SELECT
      p_proposal_id,
      TRIM(item->>'name'),
      item->>'description',
      NULLIF(item->>'reminder', ''),
      NULLIF(item->>'date', '')::TIMESTAMPTZ,
      ordinality - 1
    FROM jsonb_array_elements(p_itinerary)
      WITH ORDINALITY AS entries(item, ordinality);
  END IF;
END;
$$;
