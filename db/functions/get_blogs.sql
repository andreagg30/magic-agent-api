CREATE OR REPLACE FUNCTION get_blogs()
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_blog_by_id(blog.id)
  FROM blogs blog
  ORDER BY blog.created_at DESC;
$$;
