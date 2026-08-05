CREATE OR REPLACE FUNCTION update_form(
    p_form_id UUID,
    p_name TEXT,
    p_description TEXT,
    p_is_active BOOLEAN,
    p_show_appbar BOOLEAN
)
RETURNS VOID
LANGUAGE sql
AS $$
    UPDATE forms
    SET
        name = TRIM(p_name),
        description = p_description,
        is_active = p_is_active,
        show_appbar = p_show_appbar
    WHERE id = p_form_id;
$$;
--