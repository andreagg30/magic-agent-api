import { Router } from "express";
import formController from "../controllers/forms.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { saveFormValidator, formIdParamValidator } from "../validators/forms.js";
import { validateRequest } from "../validators/validateRequest.js";
import multer from "multer";

const router = Router();

const imageUpload = multer({
  storage: multer.memoryStorage(),
  // Las imágenes viajan como partes binarias y no pasan por express.json.
  // No se establece fileSize: Multer/Busboy no limita el tamaño del archivo.
  limits: { fieldSize: Number.MAX_SAFE_INTEGER },
  fileFilter: (_req, file, callback) => {
    callback(null, file.mimetype.startsWith("image/"));
  },
});

router.post(
  "/save",
  requireAuth,
  imageUpload.array("images"),
  formController.parseMultipartPayload,
  saveFormValidator,
  validateRequest,
  formController.saveForm,
);
router.get("/", requireAuth, formController.getForms);
router.get("/:id", requireAuth, formIdParamValidator, validateRequest, formController.getFormById);
router.delete("/:id", requireAuth, formIdParamValidator, validateRequest, formController.deleteForm);

export default router;
