CREATE OR REPLACE FUNCTION delete_course(p_course_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM courses WHERE id = p_course_id;
  RETURN FOUND;
END;
$$;
