import { body, param } from "express-validator";

export const saveFormValidator = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("El nombre del formulario es obligatorio"),
  body("description")
    .optional({ nullable: true })
    .isString()
    .withMessage("La descripción debe ser texto"),
  body("isActive")
    .isBoolean()
    .withMessage("isActive debe ser booleano"),
  body("showAppbar")
    .isBoolean()
    .withMessage("showAppbar debe ser booleano"),
  body("sections")
    .isArray({ min: 1 })
    .withMessage("Debe haber al menos una sección"),
  body("sections.*.name")
    .trim()
    .notEmpty()
    .withMessage("El nombre de la sección es obligatorio"),
  body("sections.*.description")
    .optional({ nullable: true })
    .isString()
    .withMessage("La descripción de la sección debe ser texto"),
  body("sections.*.questions")
    .isArray({ min: 1 })
    .withMessage("Cada sección debe contener al menos una pregunta"),
  body("sections.*.questions.*.question")
    .trim()
    .notEmpty()
    .withMessage("La pregunta es obligatoria"),
  body("sections.*.questions.*.type")
    .isObject()
    .withMessage("El tipo de pregunta debe ser un objeto"),
  body("sections.*.questions.*.type.value")
    .trim()
    .notEmpty()
    .withMessage("El tipo de pregunta debe tener un valor"),
  body("sections.*.questions.*.type.label")
    .trim()
    .notEmpty()
    .withMessage("El tipo de pregunta debe tener una etiqueta"),
  body("sections.*.questions.*.isRequired")
    .optional()
    .isBoolean()
    .withMessage("isRequired debe ser booleano"),
  body("sections.*.questions.*.addAditionalInfo")
    .optional()
    .isBoolean()
    .withMessage("addAditionalInfo debe ser booleano"),
  body("sections.*.questions.*.aditionalInfo")
    .optional({ nullable: true })
    .isString()
    .withMessage("aditionalInfo debe ser texto"),
  body("sections.*.questions.*.addImage")
    .optional()
    .isBoolean()
    .withMessage("addImage debe ser booleano"),
  body("sections.*.questions.*.image")
    .optional({ nullable: true })
    .isObject()
    .withMessage("image debe ser un objeto"),
  body("sections.*.questions.*.maxLength")
    .optional({ nullable: true })
    .custom((value) => {
      if (value === null || value === undefined || value === "") return true;
      return /^\d+$/.test(String(value));
    })
    .withMessage("maxLength debe ser un número válido"),
  body("sections.*.questions.*.hasOther")
    .optional()
    .isBoolean()
    .withMessage("hasOther debe ser booleano"),
  body("sections.*.questions.*.otherSection")
    .optional({ nullable: true })
    .isObject()
    .withMessage("otherSection debe ser un objeto"),
  body("sections.*.questions.*.addExtraValidations")
    .optional()
    .isBoolean()
    .withMessage("addExtraValidations debe ser booleano"),
  body("sections.*.questions.*.shortTextValidations")
    .optional({ nullable: true })
    .isObject()
    .withMessage("shortTextValidations debe ser un objeto"),
  body("sections.*.questions.*.checkboxValidations")
    .optional({ nullable: true })
    .isObject()
    .withMessage("checkboxValidations debe ser un objeto"),
  body("sections.*.questions.*.optionValidations")
    .optional({ nullable: true })
    .isObject()
    .withMessage("optionValidations debe ser un objeto"),
  body("sections.*.questions.*.options")
    .isArray()
    .withMessage("options debe ser un arreglo"),
  body("sections.*.questions.*.options.*.option")
    .optional({ nullable: true })
    .isString()
    .withMessage("Cada opción debe ser texto"),
];

export const formIdParamValidator = [
  param("id")
    .isUUID()
    .withMessage("El id del formulario debe ser un UUID válido"),
];
