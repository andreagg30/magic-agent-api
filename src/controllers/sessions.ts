import { pool } from "../database/db-connection.js";
import { type Request, type Response } from "express";
import jwt from "jsonwebtoken";
import {
  clearAuthCookies,
  createAccessToken,
  createRefreshToken,
  setAuthCookies,
} from "../utils/auth.js";
import { hashToken } from "../utils/hash-token.js";
import sessionService from "../services/sessions.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function refreshSession(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    const oldRefreshToken = req.cookies.refreshToken;

    if (!oldRefreshToken) {
      return sendError({
        res,
        statusCode: 401,
        message: "NoTokenprovided",
      });
    }

    let decoded: {
      userId: string;
      email: string;
    };

    try {
      decoded = jwt.verify(
        oldRefreshToken,
        process.env.JWT_REFRESH_SECRET as string,
      ) as {
        userId: string;
        email: string;
      };
    } catch {
      clearAuthCookies(res);

      return sendSuccess({
        res,
        statusCode: 401,
        message: "InvalidRefreshToken",
      });
    }

    const oldRefreshTokenHash = hashToken(oldRefreshToken);

    await client.query("BEGIN");

    const session = await sessionService.getSessionByTokenHashAndUser({
      refreshTokenHash: oldRefreshTokenHash,
      userId: decoded.userId,
      client,
    });

    if (!session) {
      await client.query("ROLLBACK");
      clearAuthCookies(res);

      return sendError({
        res,
        message: "SessionNotFound",
        statusCode: 401,
      });
    }

    if (session.revoked_at) {
      await client.query("ROLLBACK");
      clearAuthCookies(res);

      return sendSuccess({
        message: "SessionRevoked",
        statusCode: 401,
        res,
      });
    }

    if (new Date(session.expires_at) < new Date()) {
      await client.query("ROLLBACK");
      clearAuthCookies(res);

      return sendError({
        res,
        message: "SessionExpired",
        statusCode: 401,
      });
    }

    const newAccessToken = createAccessToken({
      userId: decoded.userId,
      email: decoded.email,
    });

    const newRefreshToken = createRefreshToken({
      userId: decoded.userId,
      email: decoded.email,
    });

    const newRefreshTokenHash = hashToken(newRefreshToken);

    await sessionService.revokeSession({ id: session.id, client });

    await sessionService.addSession({
      id: decoded.userId,
      refreshTokenHash: newRefreshTokenHash,
      user_agent: req.headers["user-agent"] || null,
      ip: req.ip || null,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      client,
    });

    await client.query("COMMIT");

    setAuthCookies(res, newAccessToken, newRefreshToken);

    return sendSuccess({ res });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);

    console.error(error);

    clearAuthCookies(res);

    return sendError({
      res,
    });
  } finally {
    client.release();
  }
};

export default {
  refreshSession,
};
