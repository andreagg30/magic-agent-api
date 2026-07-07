import { Router } from "express";
import userController from "../controllers/users.js";
import { addUserValidator, getUserValidator } from "../validators/users.js";
import { validateRequest } from "../validators/validateRequest.js";
import { requireAuth } from "../middlewares/require-auth.js";

const router = Router();

router.post("/logout", userController.logout);

router.post("/login", getUserValidator, validateRequest, userController.login);

router.post(
  "/signup",
  addUserValidator,
  validateRequest,
  userController.signUp,
);

router.get("/getProfile", requireAuth, userController.getUserById);

export default router;
