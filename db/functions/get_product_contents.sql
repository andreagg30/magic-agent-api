CREATE OR REPLACE FUNCTION get_product_contents(p_product_id UUID)
RETURNS JSONB LANGUAGE sql STABLE AS $$
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'id', content.id, 'title', content.title, 'buttonText', content.button_text,
    'goTo', content.go_to,
    'type', jsonb_build_object('label', content_type.label, 'value', content_type.id),
    'description', content.description, 'image', content.image,
    'imageAttributes', content.image_attributes,
    'imageDirection', CASE WHEN direction.id IS NULL THEN NULL ELSE
      jsonb_build_object('label', direction.label, 'value', direction.id) END,
    'index', content.content_index
  ) ORDER BY content.position), '[]'::JSONB)
  FROM product_contents content
  JOIN catalog content_type ON content_type.id = content.type_id
  LEFT JOIN catalog direction ON direction.id = content.image_direction_id
  WHERE content.product_id = p_product_id;
$$;
