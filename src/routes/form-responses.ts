import { Router } from "express";
import formResponseController from "../controllers/form-responses.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  createFormResponseValidator,
  responseFormIdParamValidator,
  responseIdParamValidator,
  updateFormResponseStatusValidator,
} from "../validators/form-responses.js";

const router = Router();

router.post("/", createFormResponseValidator, validateRequest, formResponseController.create);
router.get("/all", requireAuth, formResponseController.getAll);
router.get("/form/:formId", requireAuth, responseFormIdParamValidator, validateRequest, formResponseController.getAll);
router.get("/:id", requireAuth, responseIdParamValidator, validateRequest, formResponseController.getById);
router.patch("/:id/status", requireAuth, updateFormResponseStatusValidator, validateRequest, formResponseController.updateStatus);
router.delete("/:id", requireAuth, responseIdParamValidator, validateRequest, formResponseController.remove);

export default router;
