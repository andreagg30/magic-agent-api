DO $$
DECLARE
  column_record RECORD;
BEGIN
  FOR column_record IN
    SELECT
      table_schema,
      table_name,
      column_name
    FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND data_type = 'character varying'
      AND character_maximum_length >= 300
  LOOP
    EXECUTE format(
      'ALTER TABLE %I.%I ALTER COLUMN %I TYPE TEXT',
      column_record.table_schema,
      column_record.table_name,
      column_record.column_name
    );
  END LOOP;
END;
$$;
