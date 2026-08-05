import { Router } from "express";
import formController from "../controllers/forms.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { saveFormValidator, formIdParamValidator } from "../validators/forms.js";
import { validateRequest } from "../validators/validateRequest.js";

const router = Router();

router.post("/save", requireAuth, saveFormValidator, validateRequest, formController.saveForm);
router.get("/", requireAuth, formController.getForms);
router.get("/:id", requireAuth, formIdParamValidator, validateRequest, formController.getFormById);
router.delete("/:id", requireAuth, formIdParamValidator, validateRequest, formController.deleteForm);

export default router;
