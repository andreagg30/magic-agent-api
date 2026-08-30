import { type Request, type Response } from "express";
import bcrypt from "bcrypt";
import userService from "../services/users.js";
import otpService from "../services/otps.js";
import sessionService from "../services/sessions.js";
import {
  clearAuthCookies,
  createAccessToken,
  createRefreshToken,
  setAuthCookies,
} from "../utils/auth.js";
import { pool } from "../database/db-connection.js";
import { hashToken } from "../utils/hash-token.js";
import { AuthRequest } from "../middlewares/require-auth.js";
import { sendError, sendSuccess } from "../utils/api-response.js";

async function login(req: Request, res: Response) {
  const client = await pool.connect();
  const { email, password } = req.body;
  try {
    await client.query("BEGIN");

    const existingUser = await userService.getUserLogin({ email, client });

    if (!existingUser) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 409,
        message: "EmailPasswordError",
      });
    }

    const isPasswordValid = await bcrypt.compare(
      password,
      existingUser.password_hash,
    );

    if (!isPasswordValid) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        message: "PasswordError",
      });
    }

    const payload = {
      userId: existingUser.id,
      email: email,
    };

    const accessToken = createAccessToken(payload);
    const refreshToken = createRefreshToken(payload);

    const refreshTokenHash = hashToken(refreshToken);

    await sessionService.addSession({
      id: existingUser.id,
      refreshTokenHash,
      user_agent: req.headers["user-agent"] || null,
      ip: req.ip || null,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      client,
    });

    await client.query("COMMIT");

    setAuthCookies(res, accessToken, refreshToken);

    if (existingUser?.email_verified === false) {
      await otpService.createAndSendOtp({
        userId: existingUser.id,
        client,
        email,
      });
    }

    return sendSuccess({
      res,
      statusCode: 201,
      data: {
        email_verified: existingUser.email_verified,
      },
    });
  } catch (error: any) {
    console.error(error);
    await client.query("ROLLBACK");
    return sendError({
      res,
    });
  } finally {
    client.release();
  }
}

async function signUp(req: Request, res: Response) {
  const client = await pool.connect();

  const { first_name, last_name, email, phone, password } = req.body;

  try {
    await client.query("BEGIN");

    const existingUser = await userService.someUserByEmail({ email, client });

    if (existingUser) {
      return sendError({
        res,
        statusCode: 409,
        message: "EmailAlreadyRegistered",
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const id = await userService.signUp({
      first_name,
      last_name,
      email,
      phone,
      password: passwordHash,
      user_type_id: 2, // user_type_id for regular users
      client,
    });

    const payload = {
      userId: id,
      email: email,
    };

    const accessToken = createAccessToken(payload);
    const refreshToken = createRefreshToken(payload);

    const refreshTokenHash = hashToken(refreshToken);

    await sessionService.addSession({
      id: id,
      refreshTokenHash,
      user_agent: req.headers["user-agent"] || null,
      ip: req.ip || null,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      client,
    });

    await otpService.createAndSendOtp({
      userId: id,
      client,
      email,
    });

    await client.query("COMMIT");

    setAuthCookies(res, accessToken, refreshToken);

    return sendSuccess({
      res,
      data: {
        user_id: id,
      },
    });
  } catch (error: any) {
    console.error(error);
    await client.query("ROLLBACK");
    return sendError({
      res,
    });
  } finally {
    client.release();
  }
}

async function logout(req: Request, res: Response) {

  try {
    const refreshToken = req.cookies.refreshToken;

    if (refreshToken) {
      const refreshTokenHash = hashToken(refreshToken);

      await await pool.query(
        `
            SELECT revoke_session_by_token_hash($1::text)
        `,
        [refreshTokenHash],
      );
    }

    clearAuthCookies(res);

    return sendSuccess({ res });
  } catch (error) {
    console.error(error);

    clearAuthCookies(res);

    return sendError({
      res,
    });
  }
}

async function getUserById(req: AuthRequest, res: Response) {
  try {
    const userReq = req.user;
    if (!userReq?.userId) {
      return sendError({
        message: "UserNotFound",
        res,
      });
    }

    const user = await userService.getUserById({ userId: userReq.userId });

    if (!user) {
      return sendError({
        message: "UserNotFound",
        res,
      });
    }

    return sendSuccess({
      res,
      data: {
        user,
      },
    });
  } catch {
    return sendError({ res });
  }
}

async function getAll(req: Request, res: Response) {
  try {
    const users = await userService.getAll();
    return sendSuccess({ res, data: { users } });
  } catch (error) {
    console.error(error);
    return sendError({ res });
  }
}

export default {
  getAll,
  login,
  getUserById,
  signUp,
  logout,
};
