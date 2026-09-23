import { body, param } from "express-validator";

export const saveFormValidator = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("El nombre del formulario es obligatorio")
    .isLength({ max: 50 })
    .withMessage("name no puede exceder 50 caracteres"),
  body("lastName")
    .optional({ nullable: true, checkFalsy: true })
    .trim()
    .isLength({ max: 50 })
    .withMessage("lastName no puede exceder 50 caracteres"),
  body("location")
    .optional({ nullable: true, checkFalsy: true })
    .trim()
    .isLength({ max: 70 })
    .withMessage("location no puede exceder 70 caracteres"),
  body("phone")
    .optional({ nullable: true, checkFalsy: true })
    .trim()
    .isLength({ max: 20 })
    .withMessage("phone no puede exceder 20 caracteres")
    .matches(/^[0-9+\-\s()]+$/)
    .withMessage("phone contiene caracteres no válidos"),
  body("email")
    .optional({ nullable: true, checkFalsy: true })
    .trim()
    .isEmail()
    .withMessage("email debe ser válido")
    .isLength({ max: 255 })
    .withMessage("email no puede exceder 255 caracteres")
    .normalizeEmail(),
  body("secondEmail")
    .optional({ nullable: true, checkFalsy: true })
    .trim()
    .isEmail()
    .withMessage("secondEmail debe ser válido")
    .isLength({ max: 255 })
    .withMessage("secondEmail no puede exceder 255 caracteres")
    .normalizeEmail(),
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
  body("sections.*.questions.*")
    .custom((question: { addImage?: boolean; image?: { src?: unknown } }) => {
      if (!question?.addImage) return true;
      return (
        !!question.image &&
        typeof question.image.src === "string" &&
        question.image.src.trim().length > 0
      );
    })
    .withMessage("Cuando addImage es true, image.src es obligatorio"),
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
