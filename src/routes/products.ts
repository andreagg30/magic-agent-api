import { Router } from "express";
import productController from "../controllers/products.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  getProductsValidator,
  productIdParamValidator,
  saveProductValidator,
} from "../validators/products.js";

const router = Router();

router.use(requireAuth);
router.get("/", getProductsValidator, validateRequest, productController.getAll);
router.post("/", saveProductValidator, validateRequest, productController.create);
router.put(
  "/:id",
  productIdParamValidator,
  saveProductValidator,
  validateRequest,
  productController.update,
);
router.delete(
  "/:id",
  productIdParamValidator,
  validateRequest,
  productController.remove,
);

export default router;
