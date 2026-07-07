import { PoolClient } from "pg";
import { hashOtp } from "../utils/hash-otp.js";
import { generateOtp } from "../utils/generate-otp.js";
import otpService from "../services/otps.js";
import mailService from "../services/mails.js";

const createOtp = async ({
  userId,
  client,
  otp,
}: {
  userId: string;
  client: PoolClient;
  otp: string;
}) => {
  const otpHash = hashOtp(otp);
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
  const result = await client.query(
    `
    SELECT add_user_verification_code(
    $1::uuid,
    $2::text,
    $3::timestamp
    ) AS verification_code_id
      `,
    [userId, otpHash, expiresAt],
  );

  const verificationCodeId = result.rows[0].verification_code_id;

  return verificationCodeId;
};

async function createAndSendOtp({
  userId,
  client,
  email,
}: {
  userId: string;
  client: PoolClient;
  email: string;
}) {
  const otp = generateOtp();

  const createOtp = await otpService.createOtp({
    userId,
    client,
    otp,
  });

  if (createOtp) {
    await mailService.sendOtp({
      otp: otp,
      email: email,
    });
  }
}

export default {
  createOtp,
  createAndSendOtp
};
