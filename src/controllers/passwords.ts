import type { Request, Response } from "express";
import { pool } from "../database/db-connection.js";
import { sendError, sendSuccess } from "../utils/api-response.js";
import userService from "../services/users.js";
import passwordService from "../services/passwords.js";
import bcrypt from "bcrypt";

export async function forgotPassword(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    const { email } = req.body as { email: string };

    if (!email) {
      return sendError({
        res,
        statusCode: 400,
        message: "MissingFields",
      });
    }

    const user = await userService.getUserLogin({
      email: email,
      client,
    });

    if (!user) {
      return sendSuccess({
        res,
        message: "If the email exists, a reset code was sent",
      });
    }

    await client.query("BEGIN");

    await passwordService.getResetPasswordOtp({
      client,
      userId: user.id,
      email,
    });
    await client.query("COMMIT");

    return sendSuccess({
      res,
      message: "If the email exists, a reset code was sent",
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);

    console.error(error);

    return sendError({ res });
  } finally {
    client.release();
  }
}

export async function resetPassword(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    const { email, otp, newPassword } = req.body as {
      email: string;
      otp: string;
      newPassword: string;
    };

    if (!email || !otp || !newPassword) {
      return sendError({
        res,
        statusCode: 400,
        message: "MissingFields",
      });
    }

    const user = await userService.getUserLogin({
      email: email,
      client,
    });

    if (!user) {
      return sendError({
        res,
        statusCode: 400,
        message: "InvalidExpiredCode",
      });
    }

    await client.query("BEGIN");

    const resetCode = await passwordService.getResetOtpByUserHash({
      client,
      otp: otp,
      userId: user.id,
    });

    if (!resetCode) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 400,
        message: "InvalidResetCode",
      });
    }

    if (resetCode.used_at) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 400,
        message: "OtpAlreadyUsed",
      });
    }

    if (new Date(resetCode.expires_at) < new Date()) {
      await client.query("ROLLBACK");

      return sendError({
        message: "OtpExpired",
        res,
        statusCode: 400,
      });
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);

    await passwordService.resetUserPassword({
      client,
      userId: user.id,
      passwordHash,
      resetOtpId: resetCode.id,
    });

    await client.query("COMMIT");

    return sendSuccess({ res });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);

    console.error(error);

    return sendError({ res });
  } finally {
    client.release();
  }
}
