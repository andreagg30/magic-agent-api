CREATE OR REPLACE FUNCTION get_term_by_id(p_term_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', term.id,
    'name', term.name,
    'image', term.image,
    'icon', term.icon,
    'description', term.description,
    'isActive', term.is_active,
    'categories', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', category.id,
        'name', category.name
      ) ORDER BY link.position)
      FROM term_category_links link
      JOIN term_categories category ON category.id = link.category_id
      WHERE link.term_id = term.id
    ), '[]'::JSONB),
    'attributes', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'label', attribute.label,
        'value', attribute.value
      ) ORDER BY attribute.position)
      FROM term_attributes attribute
      WHERE attribute.term_id = term.id
    ), '[]'::JSONB),
    'createdAt', term.created_at,
    'updatedAt', term.updated_at
  )
  FROM terms term
  WHERE term.id = p_term_id;
$$;
