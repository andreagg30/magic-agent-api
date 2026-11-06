import { Router } from "express";
import proposalController from "../controllers/proposals.js";
import { requireAuth } from "../middlewares/require-auth.js";
import { validateRequest } from "../validators/validateRequest.js";
import {
  getProposalsValidator,
  proposalIdParamValidator,
  proposalResponseIdParamValidator,
  saveProposalValidator,
  selectProposalValidator,
} from "../validators/proposals.js";
const router = Router();

router.use(requireAuth);
router.post(
  "/:id/selection",
  proposalIdParamValidator,
  selectProposalValidator,
  validateRequest,
  proposalController.select,
);
router.get(
  "/",
  getProposalsValidator,
  validateRequest,
  proposalController.getAll,
);
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
