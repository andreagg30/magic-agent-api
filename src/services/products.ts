import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

type ProductPayload = {
  name: string;
  description?: string | null;
  isActive: boolean;
  date?: boolean;
  dateRange: boolean;
  partyRequired: boolean;
  bdayRequired: boolean;
  productType?: { label: string; value?: string } | null;
  icon?: string | null;
};

const values = (payload: ProductPayload) => [
  payload.name,
  payload.description ?? null,
  payload.isActive,
  payload.date ?? false,
  payload.dateRange,
  payload.partyRequired,
  payload.bdayRequired,
  payload.productType?.value ?? null,
  payload.icon ?? null,
];

const getAll = async (productTypeId?: string) => {
  const result = await pool.query(
    "SELECT * FROM get_products($1::uuid)",
    [productTypeId ?? null],
  );
  return result.rows;
};

const create = async (payload: ProductPayload, client: PoolClient) => {
  const result = await client.query(
    `SELECT add_product(
      $1::text, $2::text, $3::boolean, $4::boolean, $5::boolean,
      $6::boolean, $7::boolean, $8::uuid, $9::text
    ) AS id`,
    values(payload),
  );
  return result.rows[0]?.id as string;
};

const update = async (
  id: string,
  payload: ProductPayload,
  client: PoolClient,
) => {
  const result = await client.query(
    `SELECT update_product(
      $1::uuid, $2::text, $3::text, $4::boolean, $5::boolean,
      $6::boolean, $7::boolean, $8::boolean, $9::uuid, $10::text
    ) AS updated`,
    [id, ...values(payload)],
  );
  return result.rows[0]?.updated === true;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_product($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { getAll, create, update, remove };
