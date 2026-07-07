import { PoolClient } from "pg";
import { generateOtp } from "../utils/generate-otp.js";
import { hashOtp } from "../utils/hash-otp.js";
import emailService from "../services/mails.js";

async function getResetPasswordOtp({
  userId,
  client,
  email,
}: {
  userId: string;
  client: PoolClient;
  email: string;
}) {
  const otp = generateOtp();
  const otpHash = hashOtp(otp);

  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

  const result = await client.query(
    `
  SELECT add_password_reset_code(
    $1::uuid,
    $2::text,
    $3::timestamp
  ) AS reset_code_id
  `,
    [userId, otpHash, expiresAt],
  );

  const resetCodeId = result.rows[0].reset_code_id;

  emailService.sendResetPasswordOtp({
    email,
    otp,
  });

  return resetCodeId;
}
async function getResetOtpByUserHash({
  userId,
  client,
  otp,
}: {
  userId: string;
  client: PoolClient;
  otp: string;
}) {
  const otpHash = hashOtp(otp);

  const codeResult = await client.query(
    `
  SELECT *
  FROM get_password_reset_code_by_user_and_hash(
    $1::uuid,
    $2::text
  )
  `,
    [userId, otpHash],
  );

  const code = codeResult.rows[0];

  return code;
}

async function resetUserPassword({
  userId,
  client,
  resetOtpId,
  passwordHash,
}: {
  userId: string;
  client: PoolClient;
  resetOtpId: string;
  passwordHash: string;
}) {
  await client.query(
    `
  SELECT reset_user_password(
    $1::uuid,
    $2::uuid,
    $3::text
  )
  `,
    [userId, resetOtpId, passwordHash],
  );
}

export default {
  getResetPasswordOtp,
  getResetOtpByUserHash,
  resetUserPassword,
};
