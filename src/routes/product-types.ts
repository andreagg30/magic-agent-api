import { Router } from "express";
import productTypeController from "../controllers/product-types.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  productTypeIdParamValidator,
  saveProductTypeValidator,
} from "../validators/product-types.js";

const router = Router();

router.use(requireAuth);
router.get("/", productTypeController.getAll);
router.post("/", saveProductTypeValidator, validateRequest, productTypeController.create);
router.put(
  "/:id",
  productTypeIdParamValidator,
  saveProductTypeValidator,
  validateRequest,
  productTypeController.update,
);
router.delete(
  "/:id",
  productTypeIdParamValidator,
  validateRequest,
  productTypeController.remove,
);

export default router;
