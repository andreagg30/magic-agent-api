CREATE OR REPLACE FUNCTION save_form_payload(
    p_payload JSONB
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_form_id UUID;
    v_section JSONB;
    v_question JSONB;
    v_option JSONB;
    v_section_id UUID;
    v_question_id UUID;
    v_section_position INTEGER := 0;
    v_question_position INTEGER := 0;
    v_option_position INTEGER := 0;
    v_max_length INTEGER;
BEGIN
    IF p_payload ? 'id' AND p_payload->>'id' <> '' THEN
        v_form_id := (p_payload->>'id')::uuid;
        UPDATE forms
        SET
            name = TRIM(p_payload->>'name'),
            description = NULLIF(p_payload->>'description', ''),
            is_active = COALESCE((p_payload->>'isActive')::boolean, TRUE),
            show_appbar = COALESCE((p_payload->>'showAppbar')::boolean, FALSE)
        WHERE id = v_form_id;

        DELETE FROM form_sections
        WHERE form_id = v_form_id;
    ELSE
        INSERT INTO forms (
            name,
            description,
            is_active,
            show_appbar
        ) VALUES (
            TRIM(p_payload->>'name'),
            NULLIF(p_payload->>'description', ''),
            COALESCE((p_payload->>'isActive')::boolean, TRUE),
            COALESCE((p_payload->>'showAppbar')::boolean, FALSE)
        ) RETURNING id INTO v_form_id;
    END IF;

    IF jsonb_typeof(p_payload->'sections') = 'array' THEN
        FOR v_section IN SELECT * FROM jsonb_array_elements(p_payload->'sections') LOOP
            INSERT INTO form_sections (
                form_id,
                name,
                description,
                position
            ) VALUES (
                v_form_id,
                TRIM(v_section->>'name'),
                NULLIF(v_section->>'description', ''),
                COALESCE(NULLIF(v_section->>'position', '')::integer, v_section_position)
            ) RETURNING id INTO v_section_id;

            v_question_position := 0;

            IF jsonb_typeof(v_section->'questions') = 'array' THEN
                FOR v_question IN SELECT * FROM jsonb_array_elements(v_section->'questions') LOOP
                    v_max_length := NULL;
                    IF v_question ? 'maxLength' AND (v_question->>'maxLength') ~ '^\d+$' THEN
                        v_max_length := (v_question->>'maxLength')::integer;
                    END IF;

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
                    ) VALUES (
                        v_section_id,
                        TRIM(v_question->>'question'),
                        v_question->'type'->>'value',
                        v_question->'type'->>'label',
                        COALESCE((v_question->>'isRequired')::boolean, FALSE),
                        COALESCE((v_question->>'addAditionalInfo')::boolean, FALSE),
                        NULLIF(v_question->>'aditionalInfo', ''),
                        COALESCE((v_question->>'addImage')::boolean, FALSE),
                        COALESCE(
                            NULLIF(v_question->>'path', ''),
                            NULLIF(v_question->'image'->>'src', ''),
                            NULLIF(v_question->'image'->>'path', '')
                        ),
                        COALESCE(
                            NULLIF(v_question->'image'->>'name', ''),
                            NULLIF(v_question->'image'->>'caption', ''),
                            NULLIF(v_question->'image'->>'alt', '')
                        ),
                        v_max_length,
                        COALESCE((v_question->>'hasOther')::boolean, FALSE),
                        CASE
                            WHEN jsonb_typeof(v_question->'otherSection') IS NOT NULL THEN v_question->'otherSection'
                            ELSE NULL
                        END,
                        COALESCE((v_question->>'addExtraValidations')::boolean, FALSE),
                        CASE
                            WHEN jsonb_typeof(v_question->'shortTextValidations') IS NOT NULL THEN v_question->'shortTextValidations'
                            ELSE NULL
                        END,
                        CASE
                            WHEN jsonb_typeof(v_question->'checkboxValidations') IS NOT NULL THEN v_question->'checkboxValidations'
                            ELSE NULL
                        END,
                        CASE
                            WHEN jsonb_typeof(v_question->'optionValidations') IS NOT NULL THEN v_question->'optionValidations'
                            ELSE NULL
                        END,
                        COALESCE(NULLIF(v_question->>'position', '')::integer, v_question_position)
                    ) RETURNING id INTO v_question_id;

                    v_option_position := 0;

                    IF jsonb_typeof(v_question->'options') = 'array' THEN
                        FOR v_option IN SELECT * FROM jsonb_array_elements(v_question->'options') LOOP
                            INSERT INTO question_options (
                                question_id,
                                option_text,
                                section,
                                position
                            ) VALUES (
                                v_question_id,
                                TRIM(v_option->>'option'),
                                CASE
                                    WHEN jsonb_typeof(v_option->'section') IS NOT NULL THEN v_option->'section'
                                    ELSE NULL
                                END,
                                COALESCE(NULLIF(v_option->>'position', '')::integer, v_option_position)
                            );

                            v_option_position := v_option_position + 1;
                        END LOOP;
                    END IF;

                    v_question_position := v_question_position + 1;
                END LOOP;
            END IF;

            v_section_position := v_section_position + 1;
        END LOOP;
    END IF;

    RETURN v_form_id;
END;
$$;
--