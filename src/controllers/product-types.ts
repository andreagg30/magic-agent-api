import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import productTypeService from "../services/product-types.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function getAll(_req: Request, res: Response) {
  try {
    const productTypes = await productTypeService.getAll();
    return sendSuccess({ res, data: { productTypes } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const productTypeId = await productTypeService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "ProductTypeCreated",
      data: { productTypeId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await productTypeService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ProductTypeNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ProductTypeUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await productTypeService.remove(
      req.params.id as string,
      client,
    );
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ProductTypeNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ProductTypeDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

export default { getAll, create, update, remove };
