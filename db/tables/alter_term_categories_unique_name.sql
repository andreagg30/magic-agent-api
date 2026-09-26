-- Conserva la categoría más antigua para cada nombre normalizado y mueve
-- hacia ella los vínculos de cualquier duplicado existente.
WITH category_mapping AS (
  SELECT
    id AS duplicate_id,
    MIN(id) OVER (PARTITION BY LOWER(TRIM(name))) AS canonical_id
  FROM term_categories
)
INSERT INTO term_category_links (term_id, category_id, position)
SELECT link.term_id, mapping.canonical_id, link.position
FROM term_category_links link
JOIN category_mapping mapping ON mapping.duplicate_id = link.category_id
WHERE mapping.duplicate_id <> mapping.canonical_id
ON CONFLICT (term_id, category_id) DO NOTHING;

WITH category_mapping AS (
  SELECT
    id AS duplicate_id,
    MIN(id) OVER (PARTITION BY LOWER(TRIM(name))) AS canonical_id
  FROM term_categories
)
DELETE FROM term_category_links link
USING category_mapping mapping
WHERE link.category_id = mapping.duplicate_id
  AND mapping.duplicate_id <> mapping.canonical_id;

WITH category_mapping AS (
  SELECT
    id AS duplicate_id,
    MIN(id) OVER (PARTITION BY LOWER(TRIM(name))) AS canonical_id
  FROM term_categories
)
DELETE FROM term_categories category
USING category_mapping mapping
WHERE category.id = mapping.duplicate_id
  AND mapping.duplicate_id <> mapping.canonical_id;

CREATE UNIQUE INDEX IF NOT EXISTS uq_term_categories_name_normalized
ON term_categories (LOWER(TRIM(name)));
