CREATE OR REPLACE FUNCTION add_form_section(
    p_form_id UUID,
    p_name TEXT,
    p_description TEXT DEFAULT NULL,
    p_position INTEGER DEFAULT 0
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_section_id UUID;
BEGIN
    INSERT INTO form_sections (
        form_id,
        name,
        description,
        position
    )
    VALUES (
        p_form_id,
        TRIM(p_name),
        p_description,
        p_position
    )
    RETURNING id INTO v_section_id;

    RETURN v_section_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El form_id % no existe en forms', p_form_id;
END;
$$;
--