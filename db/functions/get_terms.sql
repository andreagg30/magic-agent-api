CREATE OR REPLACE FUNCTION get_terms()
RETURNS SETOF JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT get_term_by_id(term.id)
  FROM terms term
  ORDER BY term.created_at DESC;
$$;
