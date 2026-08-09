CREATE OR REPLACE FUNCTION get_form_by_id(
    p_form_id UUID
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    is_active BOOLEAN,
    show_appbar BOOLEAN,
    sections JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        f.id,
        f.name,
        f.description,
        f.is_active,
        f.show_appbar,
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'id', s.id,
                    'name', s.name,
                    'description', s.description,
                    'sectionValidations', s.section_validations,
                    'position', s.position,
                    'questions', COALESCE(
                        (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'id', q.id,
                                    'question', q.question_text,
                                    'type', jsonb_build_object('value', q.type_value, 'label', q.type_label),
                                    'isRequired', q.is_required,
                                    'options', COALESCE(
                                        (
                                            SELECT jsonb_agg(
                                                jsonb_build_object(
                                                    'id', o.id,
                                                    'option', o.option_text,
                                                    'section', o.section
                                                )
                                                ORDER BY o.position
                                            )
                                            FROM question_options o
                                            WHERE o.question_id = q.id
                                        ), '[]'::jsonb
                                    ),
                                    'addExtraValidations', q.add_extra_validations,
                                    'shortTextValidations', q.short_text_validations,
                                    'maxLength', q.max_length,
                                    'addAditionalInfo', q.add_additional_info,
                                    'aditionalInfo', q.additional_info,
                                    'hasOther', q.has_other,
                                    'otherSection', q.other_section,
                                    'addImage', q.add_image,
                                    'image', CASE
                                        WHEN q.image_path IS NOT NULL OR q.image_name IS NOT NULL THEN
                                            jsonb_build_object(
                                                'path', q.image_path,
                                                'name', q.image_name
                                            )
                                        ELSE NULL
                                    END,
                                    'checkboxValidations', q.checkbox_validations,
                                    'optionValidations', q.option_validations
                                )
                                ORDER BY q.position
                            )
                            FROM form_questions q
                            WHERE q.section_id = s.id
                        ), '[]'::jsonb
                    )
                )
                ORDER BY s.position
            ) FILTER (WHERE s.id IS NOT NULL),
            '[]'::jsonb
        ) AS sections,
        f.created_at,
        f.updated_at
    FROM forms f
    LEFT JOIN form_sections s ON s.form_id = f.id
    WHERE f.id = p_form_id
    GROUP BY f.id;
$$;
