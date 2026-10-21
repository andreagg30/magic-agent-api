import type { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";

export type CourseDropdownOption = {
  label?: string;
  value: number;
};

export type CourseContentPayload = {
  type: CourseDropdownOption;
  title?: string | null;
  buttonText?: string | null;
  goTo?: string | null;
  description?: string | null;
  image?: string | null;
  imageAttributes?: {
    width?: number | string;
    height?: number | string;
  } | null;
  imageDirection?: CourseDropdownOption | null;
  index?: number;
};

export type CourseLessonPayload = {
  title: string;
  description: string;
  type: CourseDropdownOption | null;
  index?: number;
  youTubeUrl?: string | null;
  fileUrl?: string | null;
  blog?: CourseContentPayload[] | null;
};

export type CourseModulePayload = {
  title: string;
  lessons: CourseLessonPayload[];
};

export type CourseProductPayload = {
  id: string;
  [key: string]: unknown;
};

export type CoursePayload = {
  title: string;
  description: string;
  image?: string | null;
  isActive: boolean;
  modules: CourseModulePayload[];
  products?: CourseProductPayload[] | null;
};

const create = async (payload: CoursePayload, client: PoolClient) => {
  const result = await client.query(
    "SELECT add_course($1::jsonb) AS id",
    [JSON.stringify(payload)],
  );
  return result.rows[0]?.id as string;
};

const update = async (
  id: string,
  payload: CoursePayload,
  client: PoolClient,
) => {
  const result = await client.query(
    "SELECT update_course($1::uuid, $2::jsonb) AS updated",
    [id, JSON.stringify(payload)],
  );
  return result.rows[0]?.updated === true;
};

const getAll = async () => {
  const result = await pool.query("SELECT get_courses() AS course");
  return result.rows.map((row) => row.course);
};

const getById = async (id: string) => {
  const result = await pool.query(
    "SELECT get_course_by_id($1::uuid) AS course",
    [id],
  );
  return result.rows[0]?.course;
};

const remove = async (id: string, client: PoolClient) => {
  const result = await client.query(
    "SELECT delete_course($1::uuid) AS deleted",
    [id],
  );
  return result.rows[0]?.deleted === true;
};

export default { create, update, getAll, getById, remove };
