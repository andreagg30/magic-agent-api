import { body, param } from "express-validator";

export const productTypeIdParamValidator = [
  param("id")
    .isUUID()
    .withMessage("El id del tipo de producto debe ser un UUID válido"),
];

export const saveProductTypeValidator = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("El nombre es obligatorio")
    .isLength({ max: 50 })
    .withMessage("El nombre no puede exceder 50 caracteres"),
  body("description")
    .optional({ nullable: true })
    .isString()
    .withMessage("La descripción debe ser texto")
    .isLength({ max: 250 })
    .withMessage("La descripción no puede exceder 250 caracteres"),
  body("isActive")
    .isBoolean()
    .withMessage("isActive debe ser booleano"),
];
