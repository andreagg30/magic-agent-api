import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

type ProductTypePayload = {
  name: string;
  description?: string | null;
  isActive: boolean;
};

const getAll = async () => {
  const result = await pool.query("SELECT * FROM get_product_types()");
  return result.rows;
};

const create = async (payload: ProductTypePayload, client: PoolClient) => {
  const result = await client.query(
    `SELECT add_product_type(
      $1::text, $2::text, $3::boolean
    ) AS id`,
    [payload.name, payload.description ?? null, payload.isActive],
  );
  return result.rows[0]?.id as string;
};

const update = async (
  id: string,
  payload: ProductTypePayload,
  client: PoolClient,
) => {
  const result = await client.query(
    `SELECT update_product_type(
      $1::uuid, $2::text, $3::text, $4::boolean
    ) AS updated`,
    [id, payload.name, payload.description ?? null, payload.isActive],
  );
  return result.rows[0]?.updated === true;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_product_type($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { getAll, create, update, remove };
