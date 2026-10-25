import { body, param, query } from "express-validator";

export const productIdParamValidator = [
  param("id").isUUID().withMessage("El id del producto debe ser un UUID válido"),
];

export const getProductsValidator = [
  query("productTypeId")
    .optional()
    .isUUID()
    .withMessage("productTypeId debe ser un UUID válido"),
];

export const saveProductValidator = [
  body("contents").optional().isArray().withMessage("contents debe ser un arreglo"),
  body("contents.*").isObject({ strict: true }).withMessage("Cada contenido debe ser un objeto"),
  body("contents.*.type")
    .isObject()
    .withMessage("type del contenido debe ser un objeto"),
  body("contents.*.type.value")
    .isInt({ min: 1 })
    .withMessage("type.value del contenido debe ser un id válido"),
  body("contents.*.title")
    .optional({ nullable: true })
    .isString()
    .withMessage("title del contenido debe ser texto")
    .bail()
    .isLength({ max: 100 })
    .withMessage("title del contenido no puede exceder 100 caracteres"),
  body("contents.*.buttonText")
    .optional({ nullable: true })
    .isString()
    .withMessage("buttonText del contenido debe ser texto")
    .bail()
    .isLength({ max: 60 })
    .withMessage("buttonText del contenido no puede exceder 60 caracteres"),
  body("contents.*.goTo")
    .optional({ nullable: true })
    .isString()
    .withMessage("goTo del contenido debe ser texto"),
  body("contents.*.description")
    .optional({ nullable: true })
    .isString()
    .withMessage("description del contenido debe ser texto"),
  body("contents.*.image")
    .optional({ nullable: true })
    .isString()
    .withMessage("image del contenido debe ser texto"),
  body("contents.*.imageAttributes")
    .optional({ nullable: true })
    .isObject()
    .withMessage("imageAttributes debe ser un objeto"),
  body("contents.*.imageAttributes.width")
    .optional({ nullable: true })
    .isNumeric()
    .withMessage("imageAttributes.width debe ser numérico"),
  body("contents.*.imageAttributes.height")
    .optional({ nullable: true })
    .isNumeric()
    .withMessage("imageAttributes.height debe ser numérico"),
  body("contents.*.imageDirection")
    .optional({ nullable: true })
    .isObject()
    .withMessage("imageDirection debe ser un objeto"),
  body("contents.*.imageDirection.value")
    .optional({ nullable: true })
    .isInt({ min: 1 })
    .withMessage("imageDirection.value debe ser un id válido"),
  body("contents.*.index")
    .optional({ nullable: true })
    .isInt({ min: 0 })
    .withMessage("index del contenido debe ser un entero mayor o igual a 0"),

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
  body("isActive").isBoolean().withMessage("isActive debe ser booleano"),
  body("date")
    .optional()
    .isBoolean()
    .withMessage("date debe ser booleano"),
  body("dateRange").isBoolean().withMessage("dateRange debe ser booleano"),
  body("partyRequired")
    .isBoolean()
    .withMessage("partyRequired debe ser booleano"),
  body("bdayRequired")
    .isBoolean()
    .withMessage("bdayRequired debe ser booleano"),
  body("productType")
    .optional({ nullable: true })
    .isObject()
    .withMessage("productType debe ser un objeto"),
  body("productType.value")
    .if(body("productType").exists({ checkNull: true }))
    .isUUID()
    .withMessage("productType.value debe ser un UUID válido"),
  body("productType.label")
    .if(body("productType").exists({ checkNull: true }))
    .isString()
    .withMessage("productType.label debe ser texto"),
  body("icon")
    .optional({ nullable: true })
    .isString()
    .withMessage("icon debe ser texto")
    .isLength({ max: 50 })
    .withMessage("icon no puede exceder 50 caracteres"),
  body().custom((payload) => {
    if (payload.date && payload.dateRange) {
      throw new Error("date y dateRange no pueden estar activos al mismo tiempo");
    }
    if (payload.bdayRequired && !payload.partyRequired) {
      throw new Error("bdayRequired requiere que partyRequired esté activo");
    }
    return true;
  }),
];
