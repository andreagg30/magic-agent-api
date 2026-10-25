CREATE OR REPLACE FUNCTION sync_product_contents(p_product_id UUID, p_contents JSONB)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  -- An omitted contents field preserves existing contents on update.
  IF p_contents IS NULL THEN RETURN; END IF;
  DELETE FROM product_contents WHERE product_id = p_product_id;
  INSERT INTO product_contents (
    product_id, type_id, title, button_text, go_to, description,
    image, image_attributes, image_direction_id, content_index, position
  )
  SELECT p_product_id, (content->'type'->>'value')::INTEGER,
    NULLIF(TRIM(content->>'title'), ''), NULLIF(content->>'buttonText', ''),
    NULLIF(content->>'goTo', ''), NULLIF(content->>'description', ''),
    NULLIF(content->>'image', ''),
    CASE WHEN jsonb_typeof(content->'imageAttributes') = 'object' THEN content->'imageAttributes' ELSE NULL END,
    NULLIF(content->'imageDirection'->>'value', '')::INTEGER,
    COALESCE(NULLIF(content->>'index', '')::INTEGER, ordinality::INTEGER - 1),
    ordinality - 1
  FROM jsonb_array_elements(p_contents) WITH ORDINALITY AS entries(content, ordinality);
END;
$$;
