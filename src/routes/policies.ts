import { Router } from "express";
import policyController from "../controllers/policies.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  policyFormIdParamValidator,
  policyIdParamValidator,
  savePolicyValidator,
} from "../validators/policies.js";

const router = Router();

router.use(requireAuth);
router.get("/", policyController.getAll);
router.get(
  "/form/:formId",
  policyFormIdParamValidator,
  validateRequest,
  policyController.getByFormId,
);
router.get("/:id", policyIdParamValidator, validateRequest, policyController.getById);
router.post("/", savePolicyValidator, validateRequest, policyController.create);
router.put("/:id", policyIdParamValidator, savePolicyValidator, validateRequest, policyController.update);
router.delete("/:id", policyIdParamValidator, validateRequest, policyController.remove);

export default router;
