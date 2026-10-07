CREATE OR REPLACE FUNCTION get_blogs(p_is_active BOOLEAN)
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_blog_by_id(blog.id)
  FROM blogs blog
  WHERE p_is_active IS NULL OR blog.is_active = p_is_active
  ORDER BY blog.created_at DESC;
$$;
