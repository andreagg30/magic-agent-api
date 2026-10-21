import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import courseService from "../services/courses.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function courseError(error: any, res: Response) {
  if (error?.code === "23503") {
    return sendError({
      res,
      statusCode: 400,
      message: "InvalidCourseReference",
    });
  }
  if (["22001", "22P02", "23502", "23514"].includes(error?.code)) {
    return sendError({
      res,
      statusCode: 400,
      message: "InvalidCoursePayload",
    });
  }
  console.error(error);
  return sendError({ res });
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const courseId = await courseService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "CourseCreated",
      data: { courseId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return courseError(error, res);
  } finally {
    client.release();
  }
}

async function getAll(_req: Request, res: Response) {
  try {
    const courses = await courseService.getAll();
    return sendSuccess({ res, data: { courses } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getById(req: Request, res: Response) {
  try {
    const course = await courseService.getById(req.params.id as string);
    if (!course) {
      return sendError({ res, statusCode: 404, message: "CourseNotFound" });
    }
    return sendSuccess({ res, data: { course } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await courseService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "CourseNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "CourseUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return courseError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await courseService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "CourseNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "CourseDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return courseError(error, res);
  } finally {
    client.release();
  }
}

export default { create, getAll, getById, update, remove };
