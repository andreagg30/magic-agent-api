CREATE OR REPLACE FUNCTION get_blog_by_id(p_blog_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', blog.id,
    'title', blog.title,
    'shortDescription', blog.short_description,
    'isActive', blog.is_active,
    'categories', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'name', category.name,
        'value', category.id
      ) ORDER BY link.position)
      FROM blog_category_links link
      JOIN term_categories category ON category.id = link.category_id
      WHERE link.blog_id = blog.id
    ), '[]'::JSONB),
    'content', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', content.id,
        'type', jsonb_build_object(
          'label', type_catalog.label,
          'value', type_catalog.id
        ),
        'description', content.description,
        'image', content.image,
        'imageAttributes', content.image_attributes,
        'imageDirection', CASE
          WHEN direction_catalog.id IS NULL THEN NULL
          ELSE jsonb_build_object(
            'label', direction_catalog.label,
            'value', direction_catalog.id
          )
        END,
        'index', content.content_index
      ) ORDER BY content.position)
      FROM blog_contents content
      JOIN catalog type_catalog ON type_catalog.id = content.type_id
      LEFT JOIN catalog direction_catalog
        ON direction_catalog.id = content.image_direction_id
      WHERE content.blog_id = blog.id
    ), '[]'::JSONB),
    'createdAt', blog.created_at,
    'updatedAt', blog.updated_at
  )
  FROM blogs blog
  WHERE blog.id = p_blog_id;
$$;
