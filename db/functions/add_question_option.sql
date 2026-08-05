CREATE OR REPLACE FUNCTION add_question_option(
    p_question_id UUID,
    p_option_text TEXT,
    p_section JSONB DEFAULT NULL,
    p_position INTEGER DEFAULT 0
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_option_id UUID;
BEGIN
    INSERT INTO question_options (
        question_id,
        option_text,
        section,
        position
    )
    VALUES (
        p_question_id,
        TRIM(p_option_text),
        p_section,
        p_position
    )
    RETURNING id INTO v_option_id;

    RETURN v_option_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El question_id % no existe en form_questions', p_question_id;
END;
$$;
--