import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import blogService from "../services/blogs.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function blogError(error: any, res: Response) {
  if (error?.code === "23505") {
    return sendError({
      res,
      statusCode: 409,
      message: "DuplicateTermCategoryName",
    });
  }
  if (error?.code === "23503") {
    return sendError({ res, statusCode: 400, message: "InvalidBlogReference" });
  }
  if (["22001", "22P02", "23502", "23514"].includes(error?.code)) {
    return sendError({ res, statusCode: 400, message: "InvalidBlogPayload" });
  }
  console.error(error);
  return sendError({ res });
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const blogId = await blogService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "BlogCreated",
      data: { blogId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return blogError(error, res);
  } finally {
    client.release();
  }
}

async function getAll(req: Request, res: Response) {
  try {
    const isActive = req.query.isActive === undefined
      ? null
      : req.query.isActive === "true";
    const blogs = await blogService.getAll(isActive);
    return sendSuccess({ res, data: { blogs } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getById(req: Request, res: Response) {
  try {
    const blog = await blogService.getById(req.params.id as string);
    if (!blog) {
      return sendError({ res, statusCode: 404, message: "BlogNotFound" });
    }
    return sendSuccess({ res, data: { blog } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await blogService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "BlogNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "BlogUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return blogError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await blogService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "BlogNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "BlogDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return blogError(error, res);
  } finally {
    client.release();
  }
}

export default { create, getAll, getById, update, remove };
