import { Router } from "express";
import proposalController from "../controllers/proposals.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  proposalIdParamValidator,
  proposalResponseIdParamValidator,
  saveProposalValidator,
} from "../validators/proposals.js";

const router = Router();

router.use(requireAuth);
router.get("/", proposalController.getAll);
router.get(
  "/response/:responseId",
  proposalResponseIdParamValidator,
  validateRequest,
  proposalController.getByResponseId,
);
router.get(
  "/:id",
  proposalIdParamValidator,
  validateRequest,
  proposalController.getById,
);
router.post(
  "/",
  saveProposalValidator,
  validateRequest,
  proposalController.create,
);
router.put(
  "/:id",
  proposalIdParamValidator,
  saveProposalValidator,
  validateRequest,
  proposalController.update,
);
router.delete(
  "/:id",
  proposalIdParamValidator,
  validateRequest,
  proposalController.remove,
);

export default router;
