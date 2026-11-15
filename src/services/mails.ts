import { transporter } from "../config/nodemailer.js";
import { getOtpMail } from "../mail-templates/otp.js";
import { getPasswordResetEmail } from "../mail-templates/resetPasswordOtp.js";
import { getProposalSelectedEmail } from "../mail-templates/proposalSelected.js";

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


async function sendProposalSelected({ email, proposalId }: { email: string; proposalId: string }) {
  await transporter.sendMail({
    from: process.env.MAIL_FROM,
    to: email,
    subject: "¡Excelente elección! Hemos recibido tu confirmación",
    ...getProposalSelectedEmail(proposalId),
  });
}

export default {
    sendProposalSelected,
    sendOtp,
    sendResetPasswordOtp
}
