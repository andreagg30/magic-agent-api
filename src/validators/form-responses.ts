import { body, param } from "express-validator";

export const createFormResponseValidator = [
  body("formId").isUUID().withMessage("El formId debe ser un UUID válido"),
  body("statusId").isInt({ min: 1 }).withMessage("El statusId debe ser un entero válido"),
  body("sections").isArray({ min: 1 }).withMessage("Debe enviar al menos una sección"),
  body("sections.*.sectionName").isString().withMessage("sectionName debe ser texto"),
  body("sections.*.sectionStep").isInt({ min: 0 }).withMessage("sectionStep debe ser un entero válido"),
  body("sections.*.questions").isArray().withMessage("questions debe ser un arreglo"),
  body("sections.*.questions.*.response").optional({ nullable: true }).isString().withMessage("response debe ser texto"),
  body("sections.*.questions.*.otherResponse").optional({ nullable: true }).isString().withMessage("otherResponse debe ser texto"),
  body("sections.*.questions.*.questionName").optional({ nullable: true }).isString().withMessage("questionName debe ser texto"),
  body("sections.*.questions.*.questionKey").optional({ nullable: true }).isString().withMessage("questionKey debe ser texto"),
  body("sections.*.questions.*.selectedOption").optional({ nullable: true }).isObject().withMessage("selectedOption debe ser un objeto"),
  body("sections.*.questions.*.selectedOptions").optional({ nullable: true }).isArray().withMessage("selectedOptions debe ser un arreglo"),
  body("sections.*.questions.*.hasOther").optional({ nullable: true }).isBoolean().withMessage("hasOther debe ser booleano"),
];

export const responseIdParamValidator = [
  param("id").isUUID().withMessage("El id de la respuesta debe ser un UUID válido"),
];

export const responseFormIdParamValidator = [
  param("formId").isUUID().withMessage("El id del formulario debe ser un UUID válido"),
];

export const updateFormResponseStatusValidator = [
  ...responseIdParamValidator,
  body("statusId")
    .isInt({ min: 1 })
    .withMessage("El statusId debe ser un entero válido"),
];
