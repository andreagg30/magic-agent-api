import { param } from "express-validator";

export const categoryCodeParamValidator = [
  param("categoryCode")
    .trim()
    .notEmpty()
    .withMessage("El categoryCode es obligatorio")
    .isLength({ max: 100 })
    .withMessage("El categoryCode no puede exceder 100 caracteres"),
];
