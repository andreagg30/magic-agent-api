import { Router} from "express";
import sessionController from "../controllers/sessions.js";

const router = Router();

router.post("/refresh", sessionController.refreshSession);

export default router;