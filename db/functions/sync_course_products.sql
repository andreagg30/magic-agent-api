CREATE OR REPLACE FUNCTION sync_course_products(
  p_course_id UUID,
  p_products JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM course_product_links WHERE course_id = p_course_id;

  IF jsonb_typeof(p_products) = 'array' THEN
    INSERT INTO course_product_links (course_id, product_id, position)
    SELECT
      p_course_id,
      (product->>'id')::UUID,
      MIN(ordinality - 1)::INTEGER
    FROM jsonb_array_elements(p_products)
      WITH ORDINALITY AS entries(product, ordinality)
    GROUP BY (product->>'id')::UUID;
  END IF;
END;
$$;
