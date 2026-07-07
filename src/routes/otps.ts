import { Router } from "express";
import otpController from "../controllers/otps.js";
import { requireAuth } from "../middlewares/require-auth.js";
import {
  changeMailOtpValidator,
  verifyOtpValidator,
} from "../validators/users.js";
import { validateRequest } from "../validators/validateRequest.js";

const router = Router();

router.post("/resend", requireAuth, otpController.resendOtp);
router.post(
  "/verify-email",
  requireAuth,
  verifyOtpValidator,
  validateRequest,
  otpController.verifyEmail,
);
router.patch(
  "/change-email",
  requireAuth,
  changeMailOtpValidator,
  validateRequest,
  otpController.changeVerificationEmail,
);

export default router;
