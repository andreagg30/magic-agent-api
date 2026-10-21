CREATE OR REPLACE FUNCTION sync_course_modules(
  p_course_id UUID,
  p_modules JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_module JSONB;
  v_lesson JSONB;
  v_content JSONB;
  v_module_id UUID;
  v_lesson_id UUID;
  v_module_position INTEGER;
  v_lesson_position INTEGER;
  v_content_position INTEGER;
BEGIN
  DELETE FROM course_modules WHERE course_id = p_course_id;

  IF jsonb_typeof(p_modules) <> 'array' THEN
    RETURN;
  END IF;

  FOR v_module, v_module_position IN
    SELECT value, ordinality - 1
    FROM jsonb_array_elements(p_modules) WITH ORDINALITY
  LOOP
    INSERT INTO course_modules (course_id, title, position)
    VALUES (p_course_id, TRIM(v_module->>'title'), v_module_position)
    RETURNING id INTO v_module_id;

    IF jsonb_typeof(v_module->'lessons') = 'array' THEN
      FOR v_lesson, v_lesson_position IN
        SELECT value, ordinality - 1
        FROM jsonb_array_elements(v_module->'lessons') WITH ORDINALITY
      LOOP
        INSERT INTO course_lessons (
          module_id, title, description, type_id, lesson_index,
          youtube_url, file_url, position
        )
        VALUES (
          v_module_id,
          TRIM(v_lesson->>'title'),
          v_lesson->>'description',
          NULLIF(v_lesson->'type'->>'value', '')::INTEGER,
          NULLIF(v_lesson->>'index', '')::INTEGER,
          NULLIF(TRIM(v_lesson->>'youTubeUrl'), ''),
          NULLIF(TRIM(v_lesson->>'fileUrl'), ''),
          v_lesson_position
        )
        RETURNING id INTO v_lesson_id;

        IF jsonb_typeof(v_lesson->'blog') = 'array' THEN
          FOR v_content, v_content_position IN
            SELECT value, ordinality - 1
            FROM jsonb_array_elements(v_lesson->'blog') WITH ORDINALITY
          LOOP
            INSERT INTO course_lesson_contents (
              lesson_id, type_id, title, button_text, go_to, description,
              image, image_attributes, image_direction_id, content_index,
              position
            )
            VALUES (
              v_lesson_id,
              (v_content->'type'->>'value')::INTEGER,
              NULLIF(TRIM(v_content->>'title'), ''),
              NULLIF(v_content->>'buttonText', ''),
              NULLIF(v_content->>'goTo', ''),
              NULLIF(v_content->>'description', ''),
              NULLIF(v_content->>'image', ''),
              CASE
                WHEN jsonb_typeof(v_content->'imageAttributes') = 'object'
                  THEN v_content->'imageAttributes'
                ELSE NULL
              END,
              NULLIF(v_content->'imageDirection'->>'value', '')::INTEGER,
              COALESCE(
                NULLIF(v_content->>'index', '')::INTEGER,
                v_content_position
              ),
              v_content_position
            );
          END LOOP;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
END;
$$;
