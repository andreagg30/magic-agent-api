import { Router } from "express";
import userController from "../controllers/users.js";
import { addUserValidator, getUserValidator, userIdValidator, updateUserValidator } from "../validators/users.js";
import { validateRequest } from "../validators/validateRequest.js";
import { requireAuth } from "../middlewares/require-auth.js";

const router = Router();

router.get("/", requireAuth, userController.getAll);

router.post("/logout", userController.logout);

router.post("/login", getUserValidator, validateRequest, userController.login);

router.post(
  "/signup",
  addUserValidator,
  validateRequest,
  userController.signUp,
);

router.get("/getProfile", requireAuth, userController.getUserById);

router.get("/:id", requireAuth, userIdValidator, validateRequest, userController.getByIdWithProposals);
router.put("/:id", requireAuth, userIdValidator, updateUserValidator, validateRequest, userController.update);
router.delete("/:id", requireAuth, userIdValidator, validateRequest, userController.remove);

export default router;
