import { type Request, type Response } from "express";
import { pool } from "../database/db-connection.js";
import formService from "../services/forms.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function parseMultipartPayload(req: Request, res: Response, next: () => void) {
  if (!req.is("multipart/form-data")) return next();

  if (typeof req.body.payload !== "string") {
    res.status(400).json({ message: "El campo payload es obligatorio" });
    return;
  }

  try {
    req.body = JSON.parse(req.body.payload);
    next();
  } catch {
    res.status(400).json({ message: "El payload del formulario no es JSON válido" });
  }
}

async function saveForm(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const formId = await formService.saveForm({
      payload: req.body,
      images: (req.files as Express.Multer.File[] | undefined) ?? [],
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

async function updateForm(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const result = await formService.updateForm({
      formId: req.params.id as string,
      payload: req.body,
      images: (req.files as Express.Multer.File[] | undefined) ?? [],
      client,
    });

    if (!result) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "FormNotFound" });
    }

    await client.query("COMMIT");

    const deletionResults = await formService.deleteObsoleteFormImages(
      result.obsoleteImageUrls,
    );
    for (const deletion of deletionResults) {
      if (deletion.status === "rejected") {
        console.error("No se pudo eliminar una imagen anterior del CRM", deletion.reason);
      }
    }

    return sendSuccess({
      res,
      data: { formId: result.formId },
      message: "FormUpdated",
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
    const id = req.params.id as string;

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

    const id = req.params.id as string;
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
  parseMultipartPayload,
  saveForm,
  updateForm,
  getForms,
  getFormById,
  deleteForm,
};
