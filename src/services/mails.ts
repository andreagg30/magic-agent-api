import { transporter } from "../config/nodemailer.js";
import { getOtpMail } from "../mail-templates/otp.js";
import { getPasswordResetEmail } from "../mail-templates/resetPasswordOtp.js";

async function sendOtp({ otp, email }: { otp: string; email: string }) {
  await transporter.sendMail({
    from: process.env.MAIL_FROM,
    to: email,
    subject: "Tu código de verificación",
    html: getOtpMail(otp),
  });
}

async function sendResetPasswordOtp({ otp, email }: { otp: string; email: string }) {
  await transporter.sendMail({
    from: process.env.MAIL_FROM,
    to: email,
    subject: "Tu código de verificación para reestablecer contraseña",
    html: getPasswordResetEmail(otp),
  });
}


export default {
    sendOtp,
    sendResetPasswordOtp
}