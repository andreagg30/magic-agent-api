import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

type CreateResponseInput = {
  formId: string;
  statusId: number;
  sections: Record<string, unknown>[];
  client: PoolClient;
};

const create = async ({ formId, statusId, sections, client }: CreateResponseInput) => {
  const result = await client.query(
    "SELECT add_form_response($1::uuid, $2::integer, $3::jsonb) AS id",
    [formId, statusId, JSON.stringify(sections)],
  );
  return result.rows[0]?.id as string | undefined;
};

const getById = async (id: string) => {
  const result = await pool.query("SELECT get_form_response($1::uuid) AS response", [id]);
  return result.rows[0]?.response;
};

const getAll = async () => {
  const result = await pool.query("SELECT get_form_responses($1::uuid) AS response", [null]);
  return result.rows.map((row) => row.response);
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query("SELECT delete_form_response($1::uuid) AS deleted", [id]);
  return result.rows[0]?.deleted === true;
};

const updateStatus = async (
  id: string,
  statusId: number,
  client: PoolClient,
) => {
  const result = await client.query(
    "SELECT update_form_response_status($1::uuid, $2::integer) AS updated",
    [id, statusId],
  );
  return result.rows[0]?.updated === true;
};

export default { create, getById, getAll, remove, updateStatus };
