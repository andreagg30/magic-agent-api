import { body, param } from "express-validator";

export const policyIdParamValidator = [
  param("id").isUUID().withMessage("El id de la política debe ser un UUID válido"),
];

export const savePolicyValidator = [
  body("title")
    .trim()
    .notEmpty()
    .withMessage("El título es obligatorio"),
  body("description")
    .isString()
    .withMessage("La descripción debe ser texto")
    .isLength({ max: 3600 })
    .withMessage("La descripción no puede exceder 3600 caracteres"),
  body("isActive").isBoolean().withMessage("isActive debe ser booleano"),
  body("showFooter").isBoolean().withMessage("showFooter debe ser booleano"),
  body("showWpDescription")
    .isBoolean()
    .withMessage("showWpDescription debe ser booleano"),
  body("wpDescription")
    .optional({ nullable: true })
    .isString()
    .withMessage("wpDescription debe ser texto"),
  body("forms").isArray().withMessage("forms debe ser un arreglo"),
  body("forms.*")
    .isUUID()
    .withMessage("Cada elemento de forms debe ser un UUID válido"),
  body("forms").custom((forms: string[]) => {
    if (new Set(forms).size !== forms.length) {
      throw new Error("forms no puede contener ids repetidos");
    }
    return true;
  }),
];
