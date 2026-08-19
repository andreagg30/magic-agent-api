import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

type PolicyPayload = {
  title: string;
  description: string;
  isActive: boolean;
  showFooter: boolean;
  showWpDescription: boolean;
  wpDescription?: string | null;
  forms: string[];
};

const create = async (payload: PolicyPayload, client: PoolClient) => {
  const result = await client.query(
    `SELECT add_policy(
      $1::text, $2::text, $3::boolean, $4::boolean,
      $5::boolean, $6::text, $7::uuid[]
    ) AS id`,
    [
      payload.title,
      payload.description,
      payload.isActive,
      payload.showFooter,
      payload.showWpDescription,
      payload.wpDescription ?? null,
      payload.forms,
    ],
  );
  return result.rows[0]?.id as string;
};

const getAll = async () => {
  const result = await pool.query("SELECT get_policies() AS policy");
  return result.rows.map((row) => row.policy);
};

const getById = async (id: string) => {
  const result = await pool.query("SELECT get_policy_by_id($1::uuid) AS policy", [id]);
  return result.rows[0]?.policy;
};

const update = async (id: string, payload: PolicyPayload, client: PoolClient) => {
  const result = await client.query(
    `SELECT update_policy(
      $1::uuid, $2::text, $3::text, $4::boolean, $5::boolean,
      $6::boolean, $7::text, $8::uuid[]
    ) AS updated`,
    [
      id,
      payload.title,
      payload.description,
      payload.isActive,
      payload.showFooter,
      payload.showWpDescription,
      payload.wpDescription ?? null,
      payload.forms,
    ],
  );
  return result.rows[0]?.updated === true;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query("SELECT delete_policy($1::uuid) AS deleted", [id]);
  return result.rows[0]?.deleted === true;
};

export default { create, getAll, getById, update, remove };
