CREATE OR REPLACE FUNCTION get_proposal_by_id(p_proposal_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', p.id,
    'responseId', p.response_id,
    'users', COALESCE((
      SELECT jsonb_agg(pu.user_id ORDER BY pu.position)
      FROM proposal_users pu WHERE pu.proposal_id = p.id
    ), '[]'::JSONB),
    'total', p.total,
    'totalType', p.total_type_id,
    'statusId', p.status_id,
    'showParty', p.show_party,
    'notes', p.notes,
    'gralPartyNumber', p.gral_party_number,
    'gralPartyChildren', p.gral_party_children,
    'products', COALESCE((
      SELECT jsonb_agg(
        jsonb_strip_nulls(jsonb_build_object(
          'id', pp.id,
          'productId', pp.product_id,
          'addAdditionalInfo', pp.add_additional_info,
          'fromDate', pp.from_date,
          'toDate', pp.to_date,
          'date', pp.date,
          'newParty', pp.new_party,
          'showNotes', pp.show_notes,
          'notes', pp.notes,
          'party', COALESCE((
            SELECT jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
              'id', ppm.id, 'userId', ppm.user_id, 'lastName', ppm.last_name,
              'name', ppm.name, 'dob', ppm.dob
            )) ORDER BY ppm.position)
            FROM proposal_party_members ppm
            WHERE ppm.proposal_product_id = pp.id
          ), '[]'::JSONB)
        )) ORDER BY pp.position)
      FROM proposal_products pp WHERE pp.proposal_id = p.id
    ), '[]'::JSONB),
    'party', COALESCE((
      SELECT jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
        'id', ppm.id, 'userId', ppm.user_id, 'lastName', ppm.last_name,
        'name', ppm.name, 'dob', ppm.dob
      )) ORDER BY ppm.position)
      FROM proposal_party_members ppm
      WHERE ppm.proposal_id = p.id AND ppm.proposal_product_id IS NULL
    ), '[]'::JSONB),
    'createdAt', p.created_at,
    'updatedAt', p.updated_at
  )
  FROM proposals p
  WHERE p.id = p_proposal_id;
$$;
