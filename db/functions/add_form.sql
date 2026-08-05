CREATE OR REPLACE FUNCTION add_form(
    p_name TEXT,
    p_description TEXT,
    p_is_active BOOLEAN DEFAULT TRUE,
    p_show_appbar BOOLEAN DEFAULT FALSE,
    p_sections JSONB DEFAULT '[]'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_form_id UUID;
BEGIN
    INSERT INTO forms (
        name,
        description,
        is_active,
        show_appbar,
        sections
    )
    VALUES (
        TRIM(p_name),
        p_description,
        p_is_active,
        p_show_appbar,
        COALESCE(p_sections, '[]'::jsonb)
    )
    RETURNING id INTO v_form_id;

    RETURN v_form_id;
END;
$$;
--