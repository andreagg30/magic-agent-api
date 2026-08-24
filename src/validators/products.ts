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
