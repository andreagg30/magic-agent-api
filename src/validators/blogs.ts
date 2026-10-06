import { body, param } from "express-validator";

export const blogIdParamValidator = [
  param("id").isUUID().withMessage("El id del blog debe ser un UUID válido"),
];

export const saveBlogValidator = [
  body("title")
    .trim()
    .notEmpty()
    .withMessage("title es obligatorio")
    .isLength({ max: 100 })
    .withMessage("title no puede exceder 100 caracteres"),
  body("shortDescription")
    .optional({ nullable: true })
    .isString()
    .withMessage("shortDescription debe ser texto"),
  body("isActive")
    .optional({ nullable: true })
    .isBoolean({ strict: true })
    .withMessage("isActive debe ser booleano"),
  body("categories")
    .isArray()
    .withMessage("categories debe ser un arreglo")
    .custom((categories: Array<{ value?: number }>) => {
      if (!Array.isArray(categories)) return true;
      const ids = categories
        .map((category) => category?.value)
        .filter((id): id is number => id !== undefined && id !== null);
      return new Set(ids).size === ids.length;
    })
    .withMessage("categories no puede contener values repetidos"),
  body("categories.*")
    .isObject()
    .withMessage("Cada category debe ser un objeto")
    .custom((category: { value?: unknown; name?: unknown }) => {
      if (category.value !== undefined && category.value !== null) return true;
      return typeof category.name === "string" && category.name.trim().length > 0;
    })
    .withMessage("Una category sin value debe incluir name"),
  body("categories.*.value")
    .optional({ nullable: true })
    .isInt({ min: 1 })
    .withMessage("El value de category debe ser un entero válido"),
  body("categories.*.name")
    .optional({ nullable: true })
    .isString()
    .withMessage("El nombre de category debe ser texto")
    .isLength({ max: 100 })
    .withMessage("El nombre de category no puede exceder 100 caracteres"),
  body("content")
    .isArray()
    .withMessage("content debe ser un arreglo"),
  body("content.*.type")
    .isObject()
    .withMessage("type debe ser un objeto"),
  body("content.*.type.value")
    .isInt({ min: 1 })
    .withMessage("type.value debe ser un id de catálogo válido"),
  body("content.*.description")
    .optional({ nullable: true })
    .isString()
    .withMessage("description del contenido debe ser texto"),
  body("content.*.imageAttributes")
    .optional({ nullable: true })
    .isObject()
    .withMessage("imageAttributes debe ser un objeto"),
  body("content.*.imageAttributes.width")
    .optional({ nullable: true })
    .isNumeric()
    .withMessage("imageAttributes.width debe ser NUMBER"),
  body("content.*.imageAttributes.height")
    .optional({ nullable: true })
    .isNumeric()
    .withMessage("imageAttributes.height debe ser NUMBER"),
  body("content.*.imageDirection")
    .optional({ nullable: true })
    .isObject()
    .withMessage("imageDirection debe ser un objeto"),
  body("content.*.imageDirection.value")
    .optional({ nullable: true })
    .isInt({ min: 1 })
    .withMessage("imageDirection.value debe ser un id de catálogo válido"),
  body("content.*.index")
    .isInt({ min: 0 })
    .withMessage("index debe ser un entero mayor o igual a 0"),
];
