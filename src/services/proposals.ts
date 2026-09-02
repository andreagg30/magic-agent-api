import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

export type ProposalPayload = {
  responseId?: string | null;
  users?: string[] | null;
  total?: string | number | null;
  totalType?: number | null;
  statusId?: number | null;
  showParty?: boolean | null;
  notes?: string | null;
  gralPartyNumber?: string | number | null;
  gralPartyChildren?: string | number | null;
  products?: unknown[] | null;
  party?: unknown[] | null;
};

const create = async (payload: ProposalPayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT add_proposal($1::jsonb) AS id",
    [JSON.stringify(payload)],
  );
  return result.rows[0]?.id as string;
};

const update = async (
  id: string,
  payload: ProposalPayload,
  client: PoolClient,
) => {
  const result = await client.query(
    "SELECT update_proposal($1::uuid, $2::jsonb) AS updated",
    [id, JSON.stringify(payload)],
  );
  return result.rows[0]?.updated === true;
};

const getAll = async () => {
  const result = await pool.query("SELECT get_proposals() AS proposal");
  return result.rows.map((row) => row.proposal);
};

const getById = async (id: string) => {
  const result = await pool.query(
    "SELECT get_proposal_by_id($1::uuid) AS proposal",
    [id],
  );
  return result.rows[0]?.proposal;
};

const getByResponseId = async (responseId: string) => {
  const result = await pool.query(
    "SELECT get_proposals_by_response_id($1::uuid) AS proposal",
    [responseId],
  );
  return result.rows.map((row) => row.proposal);
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_proposal($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { create, update, getAll, getById, getByResponseId, remove };
