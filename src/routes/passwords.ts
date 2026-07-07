import { Router} from "express";
import { forgotPassword, resetPassword } from "../controllers/passwords.js";
import { forgotPasswordValidator, resetPasswordValidator } from "../validators/users.js";
import { validateRequest } from "../validators/validateRequest.js";

const router = Router();

router.post(
  "/forgot",
  forgotPasswordValidator,
  validateRequest,
  forgotPassword
);

router.post(
  "/reset",
  resetPasswordValidator,
  validateRequest,
  resetPassword
);
export default router;