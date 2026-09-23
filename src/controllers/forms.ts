import { type Request, type Response } from "express";
import { pool } from "../database/db-connection.js";
import formService from "../services/forms.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function saveForm(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const formId = await formService.saveForm({ payload: req.body, client });
    await client.query("COMMIT");
    return sendSuccess({ res, statusCode: 201, data: { formId } });
  } catch (error) {
    console.error(error);
    await client.query("ROLLBACK").catch(() => null);
    return sendError({ res });
  } finally {
    client.release();
  }
}

async function updateForm(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const formId = await formService.updateForm({
      formId: req.params.id as string,
      payload: req.body,
      client,
    });
    if (!formId) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "FormNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, data: { formId }, message: "FormUpdated" });
  } catch (error) {
    console.error(error);
    await client.query("ROLLBACK").catch(() => null);
    return sendError({ res });
  } finally {
    client.release();
  }
}

async function getForms(_req: Request, res: Response) {
  try {
    const forms = await formService.getForms();
    return sendSuccess({ res, data: { forms } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getFormById(req: Request, res: Response) {
  try {
    const payload = await formService.getFormById({
      formId: req.params.id as string,
    });
    if (!payload) {
      return sendError({ res, statusCode: 404, message: "FormNotFound" });
    }
    return sendSuccess({ res, data: { payload } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function deleteForm(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await formService.deleteForm({
      formId: req.params.id as string,
      client,
    });
    await client.query("COMMIT");
    return sendSuccess({ res, message: "FormDeleted" });
  } catch (error) {
    console.error(error);
    await client.query("ROLLBACK").catch(() => null);
    return sendError({ res });
  } finally {
    client.release();
  }
}

export default { saveForm, updateForm, getForms, getFormById, deleteForm };
