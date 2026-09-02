import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import proposalService from "../services/proposals.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

function proposalError(error: any, res: Response) {
  if (error?.code === "23503") {
    return sendError({ res, statusCode: 400, message: "InvalidProposalReference" });
  }
  if (["22001", "22003", "22007", "22P02", "23505"].includes(error?.code)) {
    return sendError({ res, statusCode: 400, message: "InvalidProposalPayload" });
  }
  console.error(error);
  return sendError({ res });
}

async function create(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const proposalId = await proposalService.create(req.body, client);
    await client.query("COMMIT");
    return sendSuccess({
      res,
      statusCode: 201,
      message: "ProposalCreated",
      data: { proposalId },
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return proposalError(error, res);
  } finally {
    client.release();
  }
}

async function getAll(_req: Request, res: Response) {
  try {
    return sendSuccess({ res, data: { proposals: await proposalService.getAll() } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getById(req: Request, res: Response) {
  try {
    const proposal = await proposalService.getById(req.params.id as string);
    if (!proposal) return sendError({ res, statusCode: 404, message: "ProposalNotFound" });
    return sendSuccess({ res, data: { proposal } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function getByResponseId(req: Request, res: Response) {
  try {
    const proposals = await proposalService.getByResponseId(
      req.params.responseId as string,
    );
    return sendSuccess({ res, data: { proposals } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

async function update(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await proposalService.update(
      req.params.id as string,
      req.body,
      client,
    );
    if (!updated) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ProposalNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ProposalUpdated" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return proposalError(error, res);
  } finally {
    client.release();
  }
}

async function remove(req: Request, res: Response) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const deleted = await proposalService.remove(req.params.id as string, client);
    if (!deleted) {
      await client.query("ROLLBACK");
      return sendError({ res, statusCode: 404, message: "ProposalNotFound" });
    }
    await client.query("COMMIT");
    return sendSuccess({ res, message: "ProposalDeleted" });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);
    return proposalError(error, res);
  } finally {
    client.release();
  }
}

export default { create, getAll, getById, getByResponseId, update, remove };
