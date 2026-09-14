import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import reminderService from "../services/reminders.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function reminderError(error: any, res: Response) {
  if (error?.code === "23503") {
    return sendError({ res, statusCode: 400, message: "InvalidReminderReference" });
  }
  if (["22001", "22007", "22P02", "23502", "23505", "23514"].includes(error?.code)) {
    return sendError({ res, statusCode: 400, message: "InvalidReminderPayload" });
  }
  console.error(error);
  return sendError({ res });
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const reminderId = await reminderService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "ReminderCreated",
      data: { reminderId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return reminderError(error, res);
  } finally {
    client.release();
  }
}

async function getAll(_req: Request, res: Response) {
  try {
    const reminders = await reminderService.getAll();
    return sendSuccess({ res, data: { reminders } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getById(req: Request, res: Response) {
  try {
    const reminder = await reminderService.getById(req.params.id as string);
    if (!reminder) {
      return sendError({ res, statusCode: 404, message: "ReminderNotFound" });
    }
    return sendSuccess({ res, data: { reminder } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await reminderService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ReminderNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ReminderUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return reminderError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await reminderService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ReminderNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ReminderDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return reminderError(error, res);
  } finally {
    client.release();
  }
}

export default { create, getAll, getById, update, remove };
