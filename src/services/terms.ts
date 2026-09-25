import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

export type TermCategoryPayload = {
  id?: number;
  name?: string;
};

export type TermAttributePayload = {
  label: string;
  value: string;
};

export type TermPayload = {
  categories: TermCategoryPayload[];
  name: string;
  image?: string | null;
  icon: string;
  description?: string | null;
  attributes: TermAttributePayload[];
  isActive?: boolean;
};

const create = async (payload: TermPayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT add_term($1::jsonb) AS id",
    [JSON.stringify(payload)],
  );
  return result.rows[0]?.id as string;
};

const update = async (id: string, payload: TermPayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT update_term($1::uuid, $2::jsonb) AS updated",
    [id, JSON.stringify(payload)],
  );
  return result.rows[0]?.updated === true;
};

const getAll = async () => {
  const result = await pool.query("SELECT get_terms() AS term");
  return result.rows.map((row) => row.term);
};

const getById = async (id: string) => {
  const result = await pool.query(
    "SELECT get_term_by_id($1::uuid) AS term",
    [id],
  );
  return result.rows[0]?.term;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_term($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { create, update, getAll, getById, remove };
