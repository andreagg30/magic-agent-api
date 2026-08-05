CREATE OR REPLACE FUNCTION delete_form_question(
    p_question_id UUID
)
RETURNS VOID
LANGUAGE sql
AS $$
    DELETE FROM form_questions
    WHERE id = p_question_id;
$$;
--