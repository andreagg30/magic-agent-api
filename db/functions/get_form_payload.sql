CREATE OR REPLACE FUNCTION get_form_payload(
    p_form_id UUID
)
RETURNS JSONB
LANGUAGE sql
AS $$
SELECT jsonb_build_object(
    'id', f.id,
    'name', f.name,
    'description', f.description,
    'isActive', f.is_active,
    'showAppbar', f.show_appbar,
    'sections', COALESCE(sections.sections, '[]'::jsonb),
    'createdAt', f.created_at,
    'updatedAt', f.updated_at
)
FROM forms f
LEFT JOIN LATERAL (
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', s.id,
            'name', s.name,
            'description', s.description,
            'sectionValidations', s.section_validations,
            'position', s.position,
            'questions', COALESCE(qa.questions, '[]'::jsonb)
        ) ORDER BY s.position
    ), '[]'::jsonb) AS sections
    FROM form_sections s
    LEFT JOIN LATERAL (
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'id', q.id,
                'question', q.question_text,
                'type', jsonb_build_object('value', q.type_value, 'label', q.type_label),
                'isRequired', q.is_required,
                'options', COALESCE(oq.options, '[]'::jsonb),
                'addAditionalInfo', q.add_additional_info,
                'aditionalInfo', q.additional_info,
                'addImage', q.add_image,
                'image', CASE
                    WHEN q.image_path IS NOT NULL OR q.image_name IS NOT NULL THEN
                        jsonb_build_object(
                            'path', q.image_path,
                            'name', q.image_name
                        )
                    ELSE NULL
                END,
                'maxLength', q.max_length,
                'hasOther', q.has_other,
                'otherSection', q.other_section,
                'addExtraValidations', q.add_extra_validations,
                'shortTextValidations', q.short_text_validations,
                'checkboxValidations', q.checkbox_validations,
                'optionValidations', q.option_validations,
                'position', q.position
            ) ORDER BY q.position
        ), '[]'::jsonb) AS questions
        FROM form_questions q
        LEFT JOIN LATERAL (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'id', o.id,
                    'option', o.option_text,
                    'section', o.section,
                    'position', o.position
                ) ORDER BY o.position
            ), '[]'::jsonb) AS options
            FROM question_options o
            WHERE o.question_id = q.id
        ) oq ON true
        WHERE q.section_id = s.id
    ) qa ON true
    WHERE s.form_id = f.id
) sections ON true
WHERE f.id = p_form_id;
$$;
