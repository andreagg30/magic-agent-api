CREATE OR REPLACE FUNCTION delete_form_section(
    p_section_id UUID
)
RETURNS VOID
LANGUAGE sql
AS $$
    DELETE FROM form_sections
    WHERE id = p_section_id;
$$;
--