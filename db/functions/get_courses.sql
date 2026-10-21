CREATE OR REPLACE FUNCTION get_courses()
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_course_by_id(course.id)
  FROM courses course
  ORDER BY course.created_at DESC;
$$;
