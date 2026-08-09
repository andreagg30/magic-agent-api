CREATE OR REPLACE FUNCTION update_form_payload(
    p_form_id UUID,
    p_payload JSONB
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM forms WHERE id = p_form_id) THEN
        RAISE EXCEPTION 'El form_id % no existe en forms', p_form_id;
    END IF;

    RETURN save_form_payload(
        jsonb_set(p_payload, '{id}', to_jsonb(p_form_id::text), TRUE)
    );
END;
$$;
