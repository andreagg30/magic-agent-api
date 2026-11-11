CREATE OR REPLACE FUNCTION complete_course_lesson(p_user_id UUID, p_course_id UUID, p_lesson_id UUID)
RETURNS BOOLEAN LANGUAGE plpgsql AS $$
BEGIN
  -- Lock the lesson and module so a concurrent course edit cannot remove them mid-write.
  PERFORM lesson.id FROM course_lessons lesson
  JOIN course_modules module ON module.id = lesson.module_id
  WHERE lesson.id = p_lesson_id AND module.course_id = p_course_id
  FOR SHARE OF lesson, module;
  IF NOT FOUND THEN RETURN FALSE; END IF;

  INSERT INTO course_user_progress(user_id, course_id, lesson_id)
  VALUES (p_user_id, p_course_id, p_lesson_id)
  ON CONFLICT (user_id, course_id, lesson_id) DO NOTHING;
  RETURN TRUE;
END;
$$;
