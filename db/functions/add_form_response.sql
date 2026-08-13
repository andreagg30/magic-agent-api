CREATE OR REPLACE FUNCTION add_form_response(
  p_form_id UUID,
  p_status_id INTEGER,
  p_sections JSONB
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_response_id UUID;
  v_section_id UUID;
  v_section JSONB;
  v_question JSONB;
  v_section_position INTEGER := 0;
  v_question_position INTEGER;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM catalog
    WHERE id = p_status_id
      AND category_code = 'form_response_status'
      AND is_active = TRUE
  ) THEN
    RAISE EXCEPTION 'InvalidFormResponseStatus' USING ERRCODE = '22023';
  END IF;

  INSERT INTO form_responses (form_id, status_id, payload)
  VALUES (p_form_id, p_status_id, p_sections)
  RETURNING id INTO v_response_id;

  FOR v_section IN SELECT value FROM jsonb_array_elements(p_sections) LOOP
    INSERT INTO form_response_sections (
      response_id, section_name, section_step, section, raw_data, position
    ) VALUES (
      v_response_id,
      COALESCE(v_section->>'sectionName', ''),
      COALESCE(NULLIF(v_section->>'sectionStep', '')::integer, v_section_position),
      v_section->'section',
      v_section,
      v_section_position
    ) RETURNING id INTO v_section_id;

    v_question_position := 0;
    IF jsonb_typeof(v_section->'questions') = 'array' THEN
      FOR v_question IN SELECT value FROM jsonb_array_elements(v_section->'questions') LOOP
        INSERT INTO form_response_questions (
          response_section_id, question_name, question_key, response,
          other_response, selected_option, selected_options, has_other,
          raw_data, position
        ) VALUES (
          v_section_id,
          v_question->>'questionName',
          v_question->>'questionKey',
          v_question->>'response',
          v_question->>'otherResponse',
          v_question->'selectedOption',
          v_question->'selectedOptions',
          CASE WHEN v_question ? 'hasOther' THEN (v_question->>'hasOther')::boolean ELSE NULL END,
          v_question,
          v_question_position
        );
        v_question_position := v_question_position + 1;
      END LOOP;
    END IF;
    v_section_position := v_section_position + 1;
  END LOOP;

  RETURN v_response_id;
END;
$$;
--