CREATE OR REPLACE FUNCTION get_course_by_id(p_course_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', course.id,
    'title', course.title,
    'description', course.description,
    'image', course.image,
    'isActive', course.is_active,
    'modules', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', module.id,
        'title', module.title,
        'lessons', COALESCE((
          SELECT jsonb_agg(jsonb_build_object(
            'id', lesson.id,
            'title', lesson.title,
            'description', lesson.description,
            'type', CASE
              WHEN lesson_type.id IS NULL THEN NULL
              ELSE jsonb_build_object(
                'label', lesson_type.label,
                'value', lesson_type.id
              )
            END,
            'index', lesson.lesson_index,
            'youTubeUrl', lesson.youtube_url,
            'fileUrl', lesson.file_url,
            'blog', COALESCE((
              SELECT jsonb_agg(jsonb_build_object(
                'id', content.id,
                'title', content.title,
                'buttonText', content.button_text,
                'goTo', content.go_to,
                'type', jsonb_build_object(
                  'label', content_type.label,
                  'value', content_type.id
                ),
                'description', content.description,
                'image', content.image,
                'imageAttributes', content.image_attributes,
                'imageDirection', CASE
                  WHEN direction.id IS NULL THEN NULL
                  ELSE jsonb_build_object(
                    'label', direction.label,
                    'value', direction.id
                  )
                END,
                'index', content.content_index
              ) ORDER BY content.position)
              FROM course_lesson_contents content
              JOIN catalog content_type ON content_type.id = content.type_id
              LEFT JOIN catalog direction
                ON direction.id = content.image_direction_id
              WHERE content.lesson_id = lesson.id
            ), '[]'::JSONB)
          ) ORDER BY lesson.position)
          FROM course_lessons lesson
          LEFT JOIN catalog lesson_type ON lesson_type.id = lesson.type_id
          WHERE lesson.module_id = module.id
        ), '[]'::JSONB)
      ) ORDER BY module.position)
      FROM course_modules module
      WHERE module.course_id = course.id
    ), '[]'::JSONB),
    'products', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', product.id,
        'contents', get_product_contents(product.id),
        'name', product.name,
        'description', product.description,
        'isActive', product.is_active,
        'date', product.requires_date,
        'dateRange', product.requires_date_range,
        'partyRequired', product.party_required,
        'bdayRequired', product.bday_required,
        'productType', CASE
          WHEN product_type.id IS NULL THEN NULL
          ELSE jsonb_build_object(
            'value', product_type.id,
            'label', product_type.name
          )
        END,
        'icon', product.icon,
        'createdAt', product.created_at,
        'updatedAt', product.updated_at
      ) ORDER BY product_link.position)
      FROM course_product_links product_link
      JOIN products product ON product.id = product_link.product_id
      LEFT JOIN product_types product_type
        ON product_type.id = product.product_type_id
      WHERE product_link.course_id = course.id
    ), '[]'::JSONB),
    'createdAt', course.created_at,
    'updatedAt', course.updated_at
  )
  FROM courses course
  WHERE course.id = p_course_id;
$$;
