CREATE OR REPLACE FUNCTION get_proposal_by_id(
  p_proposal_id UUID,
  p_include_parent BOOLEAN DEFAULT TRUE,
  p_include_details BOOLEAN DEFAULT TRUE
)
RETURNS JSONB
LANGUAGE sql
STABLE
AS $$
  SELECT jsonb_build_object(
    'id', p.id,
    'parentId', p.parent_id,
    'parent', CASE
      WHEN p_include_parent AND p.parent_id IS NOT NULL
        THEN get_proposal_by_id(p.parent_id, FALSE, FALSE)
      ELSE NULL
    END,
    'children', CASE
      WHEN p_include_parent THEN COALESCE((
        SELECT jsonb_agg(
          get_proposal_by_id(child.id, FALSE, TRUE)
          ORDER BY child.created_at DESC
        )
        FROM proposals child
        WHERE child.parent_id = p.id
      ), '[]'::JSONB)
      ELSE '[]'::JSONB
    END,
    'responseId', p.response_id,
    'name', p.name,
    'description', p.description,
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
    'isActive', p.is_active,
    'isPackage', p.is_package,
    'showMainPage', p.show_main_page,
    'images', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'id', pi.id,
        'src', pi.src,
        'name', pi.name
      ) ORDER BY pi.position)
      FROM proposal_images pi
      WHERE pi.proposal_id = p.id
    ), '[]'::JSONB),
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
    'reminders', CASE
      WHEN p_include_details THEN COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'id', r.id,
          'name', r.name,
          'description', r.description,
          'isActive', r.is_active,
          'date', r.date,
          'urgencyId', r.urgency_id,
          'urgency', CASE
            WHEN urgency.id IS NULL THEN NULL
            ELSE jsonb_build_object(
              'label', urgency.label,
              'value', urgency.id
            )
          END,
          'createdAt', r.created_at,
          'updatedAt', r.updated_at
        ) ORDER BY r.date ASC, rp.position)
        FROM reminder_proposals rp
        JOIN reminders r ON r.id = rp.reminder_id
        LEFT JOIN catalog urgency ON urgency.id = r.urgency_id
        WHERE rp.proposal_id = p.id
      ), '[]'::JSONB)
      ELSE '[]'::JSONB
    END,
    'payments', CASE
      WHEN p_include_details THEN COALESCE((
        SELECT jsonb_agg(jsonb_build_object(
          'id', pay.id,
          'notes', pay.notes,
          'payment', pay.payment,
          'date', pay.date,
          'createdAt', pay.created_at,
          'updatedAt', pay.updated_at
        ) ORDER BY pay.position)
        FROM payments pay
        WHERE pay.proposal_id = p.id
      ), '[]'::JSONB)
      ELSE '[]'::JSONB
    END,
    'createdAt', p.created_at,
    'updatedAt', p.updated_at
  )
  FROM proposals p
  LEFT JOIN catalog c ON c.id = p.status_id
  LEFT JOIN catalog ty ON ty.id = p.total_type_id

  WHERE p.id = p_proposal_id;
$$;
