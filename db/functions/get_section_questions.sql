CREATE OR REPLACE FUNCTION get_section_questions(
    p_section_id UUID
)
RETURNS TABLE (
    id UUID,
    question_text TEXT,
    type_value TEXT,
    type_label TEXT,
    is_required BOOLEAN,
    add_additional_info BOOLEAN,
    additional_info TEXT,
    add_image BOOLEAN,
    image_path TEXT,
    image_name TEXT,
    max_length INTEGER,
    has_other BOOLEAN,
    other_section JSONB,
    add_extra_validations BOOLEAN,
    short_text_validations JSONB,
    checkbox_validations JSONB,
    option_validations JSONB,
    position INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        id,
        question_text,
        type_value,
        type_label,
        is_required,
        add_additional_info,
        additional_info,
        add_image,
        image_path,
        image_name,
        max_length,
        has_other,
        other_section,
        add_extra_validations,
        short_text_validations,
        checkbox_validations,
        option_validations,
        position,
        created_at,
        updated_at
    FROM form_questions
    WHERE section_id = p_section_id
    ORDER BY position;
$$;
--