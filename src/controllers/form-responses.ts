import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import formResponseService from "../services/form-responses.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const responseId = await formResponseService.create({ ...req.body, client });
    await client.query("COMMIT");
    return sendSuccess({ res, statusCode: 201, message: "FormResponseCreated", data: { responseId } });
  } catch (error: any) {
    await client.query("ROLLBACK").catch(() => null);
    if (error?.code === "23503") return sendError({ res, statusCode: 404, message: "FormNotFound" });
    if (error?.code === "22023") return sendError({ res, statusCode: 400, message: "InvalidFormResponseStatus" });
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

async function getById(req: Request, res: Response) {
  try {
    const response = await formResponseService.getById(req.params.id as string);
    if (!response) return sendError({ res, statusCode: 404, message: "FormResponseNotFound" });
    return sendSuccess({ res, data: { response } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getAll(req: Request, res: Response) {
  try {
    const formId = req.params.formId as string | undefined;
    const responses = await formResponseService.getAll(formId);
    return sendSuccess({ res, data: { responses } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await formResponseService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "FormResponseNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "FormResponseDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

export default { create, getById, getAll, remove };
