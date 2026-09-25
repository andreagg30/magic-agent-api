import { Router } from "express";
import termController from "../controllers/terms.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  saveTermValidator,
  termIdParamValidator,
} from "../validators/terms.js";

const router = Router();

router.use(requireAuth);
router.get("/", termController.getAll);
router.get(
  "/:id",
  termIdParamValidator,
  validateRequest,
  termController.getById,
);
router.post(
  "/",
  saveTermValidator,
  validateRequest,
  termController.create,
);
router.put(
  "/:id",
  termIdParamValidator,
  saveTermValidator,
  validateRequest,
  termController.update,
);
router.delete(
  "/:id",
  termIdParamValidator,
  validateRequest,
  termController.remove,
);

export default router;
