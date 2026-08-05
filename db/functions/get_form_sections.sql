CREATE OR REPLACE FUNCTION get_form_sections(
    p_form_id UUID
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    description TEXT,
    position INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        id,
        name,
        description,
        position,
        created_at,
        updated_at
    FROM form_sections
    WHERE form_id = p_form_id
    ORDER BY position;
$$;
--