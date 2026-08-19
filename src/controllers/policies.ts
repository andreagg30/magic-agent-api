import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import policyService from "../services/policies.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function policyError(error: any, res: Response) {
  if (error?.code === "23503") {
    return sendError({ res, statusCode: 400, message: "InvalidFormId" });
  }
  if (error?.code === "22001" || error?.code === "23514") {
    return sendError({ res, statusCode: 400, message: "PolicyDescriptionTooLong" });
  }
  console.error(error);
  return sendError({ res });
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const policyId = await policyService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({ res, statusCode: 201, message: "PolicyCreated", data: { policyId } });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return policyError(error, res);
  } finally {
    client.release();
  }
}

async function getAll(_req: Request, res: Response) {
  try {
    const policies = await policyService.getAll();
    return sendSuccess({ res, data: { policies } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getById(req: Request, res: Response) {
  try {
    const policy = await policyService.getById(req.params.id as string);
    if (!policy) return sendError({ res, statusCode: 404, message: "PolicyNotFound" });
    return sendSuccess({ res, data: { policy } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await policyService.update(req.params.id as string, req.body, client);
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "PolicyNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "PolicyUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return policyError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await policyService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "PolicyNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "PolicyDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

export default { create, getAll, getById, update, remove };
