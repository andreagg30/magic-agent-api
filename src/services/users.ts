import { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

const getUserLogin = async ({
  email,
  client,
}: {
  email: string;
  client: PoolClient;
}) => {
  const userResult = await client.query(
    `
      SELECT *
      FROM get_user_for_login($1)
      `,
    [email],
  );
  return userResult.rows[0];
};

const someUserByEmail = async ({
  email,
  client,
}: {
  email: string;
  client: PoolClient;
}) => {
  const result = await client.query(
    "SELECT user_exists_by_email($1) AS exists",
    [email],
  );
  return result.rows[0].exists;
};

const signUp = async ({
  first_name,
  last_name,
  email,
  phone,
  password,
  user_type_id,
  email_verified,
  client,
}: {
  first_name: string;
  last_name: string;
  email: string;
  phone?: string;
  password: string;
  user_type_id: number;
  email_verified: boolean;
  client: PoolClient;
}) => {
  const result = await client.query(
    `SELECT add_user(
            $1::varchar,
            $2::varchar,
            $3::varchar,
            $4::varchar,
            $5::text,
            $6::integer,
            $7::boolean
          ) AS user_id
          `,
    [
      first_name,
      last_name,
      email,
      phone ?? null,
      password,
      user_type_id,
      email_verified,
    ],
  );
  return result.rows[0].user_id;
};

const getUserById = async ({ userId }: { userId: string }) => {
  const result = await pool.query(
    `
  SELECT *
  FROM get_user_profile_by_id($1::uuid)
  `,
    [userId],
  );

  const user = result.rows[0];
  return user;
};

const getAll = async () => {
  const result = await pool.query("SELECT * FROM get_users()");
  return result.rows;
};

const deleteOneUser = () => {
  return;
};

export default {
  getAll,
  getUserLogin,
  signUp,
  getUserById,
  deleteOneUser,
  someUserByEmail,
};
