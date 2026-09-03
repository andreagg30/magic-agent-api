CREATE OR REPLACE FUNCTION get_proposal_by_id(p_proposal_id UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', p.id,
    'responseId', p.response_id,
    'users', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', u.id,
        'first_name', u.first_name,
        'last_name', u.last_name,
        'email', u.email,
        'phone', u.phone,
        'user_type_id', u.user_type_id,
        'email_verified', u.email_verified,
        'is_active', u.is_active,
        'last_login_at', u.last_login_at,
        'created_at', u.created_at,
        'updated_at', u.updated_at
      ) ORDER BY pu.position)
      FROM proposal_users pu
      JOIN users u ON u.id = pu.user_id
      WHERE pu.proposal_id = p.id
    ), '[]'::JSONB),
    'total', p.total,
    'statusId', p.status_id,
 'totalType', CASE
      WHEN ty.id IS NULL THEN NULL
      ELSE jsonb_build_object('id', ty.id, 'label', ty.label)
END,
    'status', CASE
      WHEN c.id IS NULL THEN NULL
      ELSE jsonb_build_object('id', c.id, 'label', c.label)
    END,
    'showParty', p.show_party,
    'notes', p.notes,
    'gralPartyNumber', p.gral_party_number,
    'gralPartyChildren', p.gral_party_children,
    'products', COALESCE((
      SELECT jsonb_agg(
        jsonb_strip_nulls(jsonb_build_object(
          'id', pp.id,
          'productId', pp.product_id,
          'productName', pro.name,
          'product', CASE
            WHEN pro.id IS NULL THEN NULL
            ELSE jsonb_build_object(
              'id', pro.id,
              'name', pro.name,
              'description', pro.description,
              'isActive', pro.is_active,
              'date', pro.requires_date,
              'dateRange', pro.requires_date_range,
              'partyRequired', pro.party_required,
              'bdayRequired', pro.bday_required,
              'productType', CASE
                WHEN pt.id IS NULL THEN NULL
                ELSE jsonb_build_object('value', pt.id, 'label', pt.name)
              END,
              'icon', pro.icon,
              'createdAt', pro.created_at,
              'updatedAt', pro.updated_at
            )
          END,
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
      FROM proposal_products pp
      LEFT JOIN products pro ON pro.id = pp.product_id
      LEFT JOIN product_types pt ON pt.id = pro.product_type_id
      WHERE pp.proposal_id = p.id
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
  LEFT JOIN catalog c ON c.id = p.status_id
  LEFT JOIN catalog ty ON ty.id = p.total_type_id

  WHERE p.id = p_proposal_id;
$$;
