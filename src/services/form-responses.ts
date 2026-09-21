import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

type CreateResponseInput = {
  formId: string;
  statusId: number;
  sections: Record<string, unknown>[];
  name: string;
  lastName?: string | null;
  location?: string | null;
  phone?: string | null;
  email?: string | null;
  secondEmail?: string | null;
  client: PoolClient;
};

const create = async ({
  formId,
  statusId,
  sections,
  name,
  lastName,
  location,
  phone,
  email,
  secondEmail,
  client,
}: CreateResponseInput) => {
  const result = await client.query(
    `SELECT add_form_response(
      $1::uuid, $2::integer, $3::jsonb, $4::varchar, $5::varchar,
      $6::varchar, $7::varchar, $8::varchar, $9::varchar
    ) AS id`,
    [
      formId,
      statusId,
      JSON.stringify(sections),
      name,
      lastName ?? null,
      location ?? null,
      phone ?? null,
      email ?? null,
      secondEmail ?? null,
    ],
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
