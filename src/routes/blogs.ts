import { Router } from "express";
import blogController from "../controllers/blogs.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  blogIdParamValidator,
  saveBlogValidator,
} from "../validators/blogs.js";

const router = Router();

router.use(requireAuth);
router.get("/", blogController.getAll);
router.get(
  "/:id",
  blogIdParamValidator,
  validateRequest,
  blogController.getById,
);
router.post(
  "/",
  saveBlogValidator,
  validateRequest,
  blogController.create,
);
router.put(
  "/:id",
  blogIdParamValidator,
  saveBlogValidator,
  validateRequest,
  blogController.update,
);
router.delete(
  "/:id",
  blogIdParamValidator,
  validateRequest,
  blogController.remove,
);

export default router;
