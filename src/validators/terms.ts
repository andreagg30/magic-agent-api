import { body, param } from "express-validator";

export const termIdParamValidator = [
  param("id").isUUID().withMessage("El id del term debe ser un UUID válido"),
];

export const saveTermValidator = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("name es obligatorio")
    .isLength({ max: 100 })
    .withMessage("name no puede exceder 100 caracteres"),
  body("image")
    .optional({ nullable: true, checkFalsy: true })
    .isString()
    .withMessage("image debe ser texto"),
  body("icon")
    .trim()
    .notEmpty()
    .withMessage("icon es obligatorio")
    .isString()
    .withMessage("icon debe ser texto"),
  body("description")
    .optional({ nullable: true })
    .isString()
    .withMessage("description debe ser texto")
    .isLength({ max: 3000 })
    .withMessage("description no puede exceder 3000 caracteres"),
  body("isActive")
    .optional({ nullable: true })
    .isBoolean({ strict: true })
    .withMessage("isActive debe ser booleano"),
  body("categories")
    .isArray()
    .withMessage("categories debe ser un arreglo")
    .custom((categories: Array<{ id?: number }>) => {
      if (!Array.isArray(categories)) return true;
      const ids = categories
        .map((category) => category?.id)
        .filter((id): id is number => id !== undefined && id !== null);
      return new Set(ids).size === ids.length;
    })
    .withMessage("categories no puede contener ids repetidos"),
  body("categories.*")
    .isObject()
    .withMessage("Cada category debe ser un objeto")
    .custom((category: { id?: unknown; name?: unknown }) => {
      if (category.id !== undefined && category.id !== null) return true;
      return typeof category.name === "string" && category.name.trim().length > 0;
    })
    .withMessage("Una category sin id debe incluir name"),
  body("categories.*.id")
    .optional({ nullable: true })
    .isInt({ min: 1 })
    .withMessage("El id de category debe ser un entero válido"),
  body("categories.*.name")
    .optional({ nullable: true })
    .isString()
    .withMessage("El nombre de category debe ser texto")
    .isLength({ max: 100 })
    .withMessage("El nombre de category no puede exceder 100 caracteres"),
  body("attributes")
    .isArray()
    .withMessage("attributes debe ser un arreglo"),
  body("attributes.*.label")
    .isString()
    .withMessage("El label del attribute debe ser texto")
    .notEmpty()
    .withMessage("El label del attribute es obligatorio"),
  body("attributes.*.value")
    .isString()
    .withMessage("El value del attribute debe ser texto")
    .notEmpty()
    .withMessage("El value del attribute es obligatorio"),
];
