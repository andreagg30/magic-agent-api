CREATE OR REPLACE FUNCTION add_form_question(
    p_section_id UUID,
    p_question_text TEXT,
    p_type_value TEXT,
    p_type_label TEXT,
    p_is_required BOOLEAN DEFAULT FALSE,
    p_add_additional_info BOOLEAN DEFAULT FALSE,
    p_additional_info TEXT DEFAULT NULL,
    p_add_image BOOLEAN DEFAULT FALSE,
    p_image_path TEXT DEFAULT NULL,
    p_image_name TEXT DEFAULT NULL,
    p_max_length INTEGER DEFAULT NULL,
    p_has_other BOOLEAN DEFAULT FALSE,
    p_other_section JSONB DEFAULT NULL,
    p_add_extra_validations BOOLEAN DEFAULT FALSE,
    p_short_text_validations JSONB DEFAULT NULL,
    p_checkbox_validations JSONB DEFAULT NULL,
    p_option_validations JSONB DEFAULT NULL,
    p_position INTEGER DEFAULT 0
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_question_id UUID;
BEGIN
    INSERT INTO form_questions (
        section_id,
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
        position
    )
    VALUES (
        p_section_id,
        TRIM(p_question_text),
        p_type_value,
        p_type_label,
        p_is_required,
        p_add_additional_info,
        p_additional_info,
        p_add_image,
        p_image_path,
        p_image_name,
        p_max_length,
        p_has_other,
        p_other_section,
        p_add_extra_validations,
        p_short_text_validations,
        p_checkbox_validations,
        p_option_validations,
        p_position
    )
    RETURNING id INTO v_question_id;

    RETURN v_question_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El section_id % no existe en form_sections', p_section_id;
END;
$$;
--