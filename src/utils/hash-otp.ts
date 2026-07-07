import crypto from "crypto";

export function hashOtp(otp: string) {
  return crypto
    .createHmac("sha256", process.env.OTP_SECRET as string)
    .update(otp)
    .digest("hex");
}