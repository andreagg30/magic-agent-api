import { Router } from "express";
import catalogController from "../controllers/catalog.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import { categoryCodeParamValidator } from "../validators/catalog.js";

const router = Router();

router.get(
  "/:categoryCode",
  requireAuth,
  categoryCodeParamValidator,
  validateRequest,
  catalogController.getByCategoryCode,
);

export default router;
