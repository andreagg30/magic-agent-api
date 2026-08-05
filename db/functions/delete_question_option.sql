CREATE OR REPLACE FUNCTION delete_question_option(
    p_option_id UUID
)
RETURNS VOID
LANGUAGE sql
AS $$
    DELETE FROM question_options
    WHERE id = p_option_id;
$$;
--