import { Router } from "express";
import courseController from "../controllers/courses.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  courseIdParamValidator,
  saveCourseValidator,
} from "../validators/courses.js";

const router = Router();

router.use(requireAuth);
router.get("/", courseController.getAll);
router.get(
  "/:id",
  courseIdParamValidator,
  validateRequest,
  courseController.getById,
);
router.post(
  "/",
  saveCourseValidator,
  validateRequest,
  courseController.create,
);
router.put(
  "/:id",
  courseIdParamValidator,
  saveCourseValidator,
  validateRequest,
  courseController.update,
);
router.delete(
  "/:id",
  courseIdParamValidator,
  validateRequest,
  courseController.remove,
);

export default router;
