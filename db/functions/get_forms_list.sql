DROP FUNCTION IF EXISTS get_forms_list();

CREATE FUNCTION get_forms_list()
RETURNS TABLE (
    id UUID,
    name VARCHAR(50),
    "lastName" VARCHAR(50),
    location VARCHAR(70),
    phone VARCHAR(20),
    email VARCHAR(255),
    "secondEmail" VARCHAR(255),
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
        last_name AS "lastName",
        location,
        phone,
        email,
        second_email AS "secondEmail",
        description,
        is_active,
        show_appbar,
        created_at,
        updated_at
    FROM forms
    ORDER BY created_at DESC;
$$;
--
