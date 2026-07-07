import { PoolClient } from "pg";

const addSession = async ({
  id,
  refreshTokenHash,
  user_agent,
  ip,
  expiresAt,
  client,
}: {
  id: string;
  refreshTokenHash: string;
  user_agent: string | null;
  ip: string | null;
  expiresAt: Date;
  client: PoolClient;
}) => {
  const result = await client.query(
    `
  SELECT add_user_session(
    $1::uuid,
    $2::text,
    $3::text,
    $4::text,
    $5::timestamp
  ) AS session_id
  `,
    [id, refreshTokenHash, user_agent, ip, expiresAt],
  );

  const sessionId = result.rows[0].session_id;

  return sessionId;
};

const getSessionByTokenHashAndUser = async ({
  refreshTokenHash,
  userId,
  client,
}: {
  refreshTokenHash: string;
  userId: string;
  client: PoolClient;
}) => {
  const sessionResult = await client.query(
    `
      SELECT *
  FROM get_session_by_token_and_id($1, $2)
      `,
    [refreshTokenHash, userId],
  );

  const session = sessionResult.rows[0];
  return session;
};

const revokeSession = async ({
  id,
  client,
}: {
  id: string;
  client: PoolClient;
}) => {
  await client.query(
    `
        SELECT revoke_session($1::uuid)
      `,
    [id],
  );
};

export default {
  addSession,
  getSessionByTokenHashAndUser,
  revokeSession,
};
