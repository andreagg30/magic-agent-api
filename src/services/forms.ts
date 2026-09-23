import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

type FormPayload = Record<string, unknown>;

const saveForm = async ({
  payload,
  client,
}: {
  payload: FormPayload;
  client: PoolClient;
}) => {
  const result = await client.query(
    "SELECT save_form_payload($1::jsonb) AS form_id",
    [payload],
  );
  return result.rows[0]?.form_id as string | undefined;
};

const updateForm = async ({
  formId,
  payload,
  client,
}: {
  formId: string;
  payload: FormPayload;
  client: PoolClient;
}) => {
  const result = await client.query(
    "SELECT update_form_payload($1::uuid, $2::jsonb) AS form_id",
    [formId, payload],
  );
  return result.rows[0]?.form_id as string | undefined;
};

const getForms = async () => {
  const result = await pool.query("SELECT * FROM get_forms_list()");
  return result.rows;
};

const getFormById = async ({ formId }: { formId: string }) => {
  const result = await pool.query(
    "SELECT get_form_payload($1::uuid) AS payload",
    [formId],
  );
  return result.rows[0]?.payload;
};

const deleteForm = async ({
  formId,
  client,
}: {
  formId: string;
  client: PoolClient;
}) => {
  await client.query("SELECT delete_form($1::uuid)", [formId]);
};

export default { saveForm, updateForm, getForms, getFormById, deleteForm };
