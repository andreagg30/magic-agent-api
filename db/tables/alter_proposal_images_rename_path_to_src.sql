DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND table_name = 'proposal_images'
      AND column_name = 'path'
  ) AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND table_name = 'proposal_images'
      AND column_name = 'src'
  ) THEN
    ALTER TABLE proposal_images RENAME COLUMN path TO src;
  END IF;
END;
$$;
