import { Router } from "express";
import reminderController from "../controllers/reminders.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  reminderIdParamValidator,
  saveReminderValidator,
} from "../validators/reminders.js";

const router = Router();

router.use(requireAuth);
router.get("/", reminderController.getAll);
router.get(
  "/:id",
  reminderIdParamValidator,
  validateRequest,
  reminderController.getById,
);
router.post(
  "/",
  saveReminderValidator,
  validateRequest,
  reminderController.create,
);
router.put(
  "/:id",
  reminderIdParamValidator,
  saveReminderValidator,
  validateRequest,
  reminderController.update,
);
router.delete(
  "/:id",
  reminderIdParamValidator,
  validateRequest,
  reminderController.remove,
);

export default router;
