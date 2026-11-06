ALTER TABLE proposals
  ADD COLUMN IF NOT EXISTS billing_country_value TEXT,
  ADD COLUMN IF NOT EXISTS billing_country_label TEXT,
  ADD COLUMN IF NOT EXISTS billing_line1 TEXT,
  ADD COLUMN IF NOT EXISTS billing_line2 TEXT,
  ADD COLUMN IF NOT EXISTS billing_city TEXT,
  ADD COLUMN IF NOT EXISTS billing_state TEXT,
  ADD COLUMN IF NOT EXISTS billing_zip TEXT,
  ADD COLUMN IF NOT EXISTS billing_phone TEXT;

-- Preserve existing addresses when upgrading from the former JSONB column.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND table_name = 'proposals' AND column_name = 'billing_address'
  ) THEN
    EXECUTE $migration$
      UPDATE proposals SET
        billing_country_value = billing_address->'country'->>'value',
        billing_country_label = billing_address->'country'->>'label',
        billing_line1 = billing_address->>'line1',
        billing_line2 = billing_address->>'line2',
        billing_city = billing_address->>'city',
        billing_state = billing_address->>'state',
        billing_zip = billing_address->>'zip',
        billing_phone = billing_address->>'phone'
      WHERE billing_address IS NOT NULL
    $migration$;
  END IF;
END;
$$;
