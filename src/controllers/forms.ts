import { type Request, type Response } from "express";
import { pool } from "../database/db-connection.js";
import formService from "../services/forms.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function saveForm(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const formId = await formService.saveForm({
      payload: req.body,
      client,
    });

    await client.query("COMMIT");

    return sendSuccess({
      res,
      statusCode: 201,
      data: { formId },
    });
  } catch (error: any) {
    console.error(error);
    await client.query("ROLLBACK").catch(() => null);
    return sendError({ res });
  } finally {
    client.release();
  }
}

async function getForms(req: Request, res: Response) {
  try {
    const forms = await formService.getForms();
    return sendSuccess({ res, data: { forms } });
  } catch (error: any) {
    console.error(error);
    return sendError({ res });
  }
}

async function getFormById(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const payload = await formService.getFormById({ formId: id });

    if (!payload) {
      return sendError({ res, statusCode: 404, message: "FormNotFound" });
    }

    return sendSuccess({ res, data: { payload } });
  } catch (error: any) {
    console.error(error);
    return sendError({ res });
  }
}

async function deleteForm(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const { id } = req.params;
    await formService.deleteForm({ formId: id, client });

    await client.query("COMMIT");

    return sendSuccess({ res, message: "FormDeleted" });
  } catch (error: any) {
    console.error(error);
    await client.query("ROLLBACK").catch(() => null);
    return sendError({ res });
  } finally {
    client.release();
  }
}

export default {
  saveForm,
  getForms,
  getFormById,
  deleteForm,
};
