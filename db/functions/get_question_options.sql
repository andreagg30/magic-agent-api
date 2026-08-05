CREATE OR REPLACE FUNCTION get_question_options(
    p_question_id UUID
)
RETURNS TABLE (
    id UUID,
    option_text TEXT,
    section JSONB,
    position INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        id,
        option_text,
        section,
        position,
        created_at,
        updated_at
    FROM question_options
    WHERE question_id = p_question_id
    ORDER BY position;
$$;
--