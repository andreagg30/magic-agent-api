import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

export type BlogDropdownOption = {
  label?: string;
  value: number;
};

export type BlogContentPayload = {
  type: BlogDropdownOption;
  title?: string | null;
  description?: string | null;
  image?: string | null;
  imageAttributes?: {
    width?: string;
    height?: string;
  } | null;
  imageDirection?: BlogDropdownOption | null;
  index: number;
};

export type BlogCategoryPayload = {
  name?: string;
  value?: number;
};

export type BlogPayload = {
  content: BlogContentPayload[];
  categories: BlogCategoryPayload[];
  title: string;
  image?: string | null;
  shortDescription?: string | null;
  isActive?: boolean;
};

const create = async (payload: BlogPayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT add_blog($1::jsonb) AS id",
    [JSON.stringify(payload)],
  );
  return result.rows[0]?.id as string;
};

const update = async (id: string, payload: BlogPayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT update_blog($1::uuid, $2::jsonb) AS updated",
    [id, JSON.stringify(payload)],
  );
  return result.rows[0]?.updated === true;
};

const getAll = async (isActive: boolean | null = null) => {
  const result = await pool.query(
    "SELECT get_blogs($1::boolean) AS blog",
    [isActive],
  );
  return result.rows.map((row) => row.blog);
};

const getById = async (id: string) => {
  const result = await pool.query(
    "SELECT get_blog_by_id($1::uuid) AS blog",
    [id],
  );
  return result.rows[0]?.blog;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_blog($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { create, update, getAll, getById, remove };
