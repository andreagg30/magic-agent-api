import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

export type ReminderPayload = {
  name: string;
  description?: string | null;
  isActive: boolean;
  date: string;
  urgency: number;
  reservation?: string[] | null;
};

const create = async (payload: ReminderPayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT add_reminder($1::jsonb) AS id",
    [JSON.stringify(payload)],
  );
  return result.rows[0]?.id as string;
};

const update = async (
  id: string,
  payload: ReminderPayload,
  client: PoolClient,
) => {
  const result = await client.query(
    "SELECT update_reminder($1::uuid, $2::jsonb) AS updated",
    [id, JSON.stringify(payload)],
  );
  return result.rows[0]?.updated === true;
};

const getAll = async () => {
  const result = await pool.query("SELECT get_reminders() AS reminder");
  return result.rows.map((row) => row.reminder);
};

const getById = async (id: string) => {
  const result = await pool.query(
    "SELECT get_reminder_by_id($1::uuid) AS reminder",
    [id],
  );
  return result.rows[0]?.reminder;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_reminder($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { create, update, getAll, getById, remove };
