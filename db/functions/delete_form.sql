CREATE OR REPLACE FUNCTION delete_form(
    p_form_id UUID
)
RETURNS VOID
LANGUAGE sql
AS $$
    DELETE FROM forms
    WHERE id = p_form_id;
$$;
--