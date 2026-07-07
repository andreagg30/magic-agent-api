import { pool } from "../database/db-connection.js";
import { sendError, sendSuccess } from "../utils/api-response.js";
import { type Request, type Response } from "express";
import { hashOtp } from "../utils/hash-otp.js";
import otpService from "../services/otps.js";
import userService from "../services/users.js";
import { AuthRequest } from "../middlewares/require-auth.js";
import bcrypt from "bcrypt";
import {
  createAccessToken,
  createRefreshToken,
  setAuthCookies,
} from "../utils/auth.js";
import { hashToken } from "../utils/hash-token.js";
import sessionService from "../services/sessions.js";
async function verifyEmail(req: AuthRequest, res: Response) {
  const client = await pool.connect();

  try {
    const { otp } = req.body;
    const userReq = req.user;

    if (!userReq?.userId) {
      return sendError({
        message: "UserNotFound",
        res,
      });
    }
    if (!userReq.email || !otp) {
      return sendError({
        res,
        statusCode: 400,
        message: "requiredFields",
      });
    }

    const user = await userService.getUserById({
      userId: userReq?.userId,
    });

    if (!user) {
      return sendError({ res, statusCode: 404, message: "UserNotFound" });
    }

    if (user.email_verified) {
      return sendSuccess({ res, message: "UserAlreadyVerified" });
    }

    const otpHash = hashOtp(otp);

    await client.query("BEGIN");

    const codeResult = await pool.query(
      `
  SELECT *
  FROM get_verification_code_by_user_and_hash(
    $1::uuid,
    $2::text
  )
  `,
      [user.id, otpHash],
    );

    const code = codeResult.rows[0];

    if (!code) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 400,
        message: "InvalidVerificationCode",
      });
    }

    if (code.used_at) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 400,
        message: "CodeAlreadyUsed",
      });
    }

    if (new Date(code.expires_at) < new Date()) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 400,
        message: "Verification code expired",
      });
    }

    await client.query(
      `
        SELECT verify_user_email_with_code(
            $1::uuid,
            $2::uuid
        )
    `,
      [user.id, code.id],
    );

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

async function resendOtp(req: AuthRequest, res: Response) {
  const client = await pool.connect();
  try {
    const userReq = req.user;
    if (!userReq?.userId) {
      return sendError({
        message: "UserNotFound",
        res,
      });
    }

    otpService.createAndSendOtp({
      client,
      email: userReq?.email,
      userId: userReq?.userId,
    });
    return sendSuccess({ res });
  } catch {
    return sendError({ res });
  }
}

async function changeVerificationEmail(req: Request, res: Response) {
  const client = await pool.connect();

  try {
    const { email, newEmail, password } = req.body;

    if (!email || !newEmail || !password) {
      return sendError({ res, statusCode: 400, message: "missing_fields" });
    }

    if (email === newEmail) {
      return sendError({
        statusCode: 400,
        res,
        message: "sameMail",
      });
    }

    await client.query("BEGIN");

    const existingUser = await userService.getUserLogin({
      email: email,
      client,
    });

    if (!existingUser) {
      await client.query("ROLLBACK");

      return sendError({
        statusCode: 404,
        message: "userNotFound",
        res,
      });
    }

    if (existingUser.email_verified) {
      await client.query("ROLLBACK");
      return sendError({
        res,
        message: "userAlreadyVerified",
        statusCode: 409,
      });
    }

    const isPasswordValid = await bcrypt.compare(
      password,
      existingUser.password_hash,
    );

    if (!isPasswordValid) {
      await client.query("ROLLBACK");
      return sendError({
        message: "PasswordError",
        res,
      });
    }

    const emailExistsResult = await userService.someUserByEmail({
      email: newEmail,
      client,
    });
    if (emailExistsResult) {
      await client.query("ROLLBACK");

      return sendError({
        res,
        statusCode: 409,
        message: "EmailAlreadyRegistered",
      });
    }

    await client.query(
      `
      SELECT update_user_email(
        $1::uuid,
        $2::varchar
        )
      `,
      [existingUser.id, newEmail],
    );

    otpService.createAndSendOtp({
      client,
      email: newEmail,
      userId: existingUser.id,
    });

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

    await otpService.createAndSendOtp({
      userId: existingUser.id,
      client,
      email,
    });

    await client.query("COMMIT");

    setAuthCookies(res, accessToken, refreshToken);

    return sendSuccess({
      res,
    });
  } catch (error) {
    await client.query("ROLLBACK").catch(() => null);

    console.error(error);

    return sendError({ res });
  } finally {
    client.release();
  }
}

export default {
  verifyEmail,
  resendOtp,
  changeVerificationEmail,
};
