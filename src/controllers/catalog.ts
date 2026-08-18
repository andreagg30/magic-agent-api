import type { Request, Response } from "express";
import catalogService from "../services/catalog.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function getByCategoryCode(req: Request, res: Response) {
  try {
    const items = await catalogService.getByCategoryCode(
      req.params.categoryCode as string,
    );
    return sendSuccess({ res, data: { items } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

export default { getByCategoryCode };
