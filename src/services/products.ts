import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

export type ProductContentPayload = {
  type: { value: number; label?: string };
  title?: string | null;
  buttonText?: string | null;
  goTo?: string | null;
  description?: string | null;
  image?: string | null;
  imageAttributes?: { width?: number | string | null; height?: number | string | null; [key: string]: unknown } | null;
  imageDirection?: { value?: number | null; label?: string } | null;
  index?: number | null;
};

export type ProductPayload = {
  contents?: ProductContentPayload[];
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
    "SELECT p.*, get_product_contents(p.id) AS contents FROM get_products($1::uuid) p",
    [productTypeId ?? null],
  );
  return result.rows;
};

const getById = async (id: string) => {
  const result = await pool.query(
    "SELECT get_product_by_id($1::uuid) AS product",
    [id],
  );
  return result.rows[0]?.product;
};

const create = async (payload: ProductPayload, client: PoolClient) => {
  const result = await client.query(
    `SELECT add_product(
      $1::text, $2::text, $3::boolean, $4::boolean, $5::boolean,
      $6::boolean, $7::boolean, $8::uuid, $9::text
    ) AS id`,
    values(payload),
  );
  const id = result.rows[0]?.id as string;
  if (payload.contents !== undefined) {
    await client.query("SELECT sync_product_contents($1::uuid, $2::jsonb)", [id, JSON.stringify(payload.contents)]);
  }
  return id;
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
  const updated = result.rows[0]?.updated === true;
  if (updated && payload.contents !== undefined) {
    await client.query("SELECT sync_product_contents($1::uuid, $2::jsonb)", [id, JSON.stringify(payload.contents)]);
  }
  return updated;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_product($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { getAll, getById, create, update, remove };
