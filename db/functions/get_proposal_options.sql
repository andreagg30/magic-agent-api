CREATE OR REPLACE FUNCTION get_proposal_options(p_proposal_id UUID, p_kind TEXT)
RETURNS JSONB LANGUAGE sql STABLE AS $$
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'id', o.id, 'description', o.description, 'total', o.total,
    'products', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', op.id, 'productId', op.product_id, 'productName', p.name,
        'product', CASE WHEN p.id IS NULL THEN NULL ELSE jsonb_build_object(
          'id', p.id, 'name', p.name, 'description', p.description,
          'contents', get_product_contents(p.id),
          'isActive', p.is_active, 'date', p.requires_date, 'dateRange', p.requires_date_range,
          'partyRequired', p.party_required, 'bdayRequired', p.bday_required,
          'icon', p.icon, 'createdAt', p.created_at, 'updatedAt', p.updated_at,
          'productType', CASE WHEN pt.id IS NULL THEN NULL ELSE jsonb_build_object('value', pt.id, 'label', pt.name) END
        ) END,
        'addAdditionalInfo', op.add_additional_info, 'fromDate', op.from_date,
        'toDate', op.to_date, 'date', op.date, 'showNotes', op.show_notes, 'notes', op.notes
      ) ORDER BY op.position)
      FROM proposal_option_products op
      LEFT JOIN products p ON p.id = op.product_id
      LEFT JOIN product_types pt ON pt.id = p.product_type_id
      WHERE op.option_id = o.id
    ), '[]'::JSONB)
  ) ORDER BY o.position), '[]'::JSONB)
  FROM proposal_options o WHERE o.proposal_id = p_proposal_id AND o.kind = p_kind;
$$;
