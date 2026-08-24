import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import productService from "../services/products.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function productError(error: any, res: Response) {
  if (error?.code === "23503") {
    return sendError({ res, statusCode: 400, message: "InvalidProductTypeId" });
  }
  if (error?.code === "23514") {
    return sendError({ res, statusCode: 400, message: "InvalidProductConfiguration" });
  }
  console.error(error);
  return sendError({ res });
}

async function getAll(req: Request, res: Response) {
  try {
    const productTypeId = req.query.productTypeId as string | undefined;
    const products = await productService.getAll(productTypeId);
    return sendSuccess({ res, data: { products } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const productId = await productService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "ProductCreated",
      data: { productId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return productError(error, res);
  } finally {
    client.release();
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await productService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ProductNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ProductUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return productError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await productService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ProductNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ProductDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    console.error(error);
    return sendError({ res });
  } finally {
    client.release();
  }
}

export default { getAll, create, update, remove };
