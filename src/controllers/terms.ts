import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import termService from "../services/terms.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function termError(error: any, res: Response) {
  if (error?.code === "23503") {
    return sendError({ res, statusCode: 400, message: "InvalidTermCategoryId" });
  }
  if (["22001", "22P02", "23502", "23514"].includes(error?.code)) {
    return sendError({ res, statusCode: 400, message: "InvalidTermPayload" });
  }
  console.error(error);
  return sendError({ res });
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const termId = await termService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "TermCreated",
      data: { termId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return termError(error, res);
  } finally {
    client.release();
  }
}

async function getAll(_req: Request, res: Response) {
  try {
    const terms = await termService.getAll();
    return sendSuccess({ res, data: { terms } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getById(req: Request, res: Response) {
  try {
    const term = await termService.getById(req.params.id as string);
    if (!term) {
      return sendError({ res, statusCode: 404, message: "TermNotFound" });
    }
    return sendSuccess({ res, data: { term } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await termService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "TermNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "TermUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return termError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await termService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "TermNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "TermDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return termError(error, res);
  } finally {
    client.release();
  }
}

export default { create, getAll, getById, update, remove };
