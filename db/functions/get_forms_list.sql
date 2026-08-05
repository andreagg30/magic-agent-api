CREATE OR REPLACE FUNCTION get_forms_list()
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    is_active BOOLEAN,
    show_appbar BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        id,
        name,
        description,
        is_active,
        show_appbar,
        created_at,
        updated_at
    FROM forms
    ORDER BY created_at DESC;
$$;
--