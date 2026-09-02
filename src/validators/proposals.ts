import { body, param } from "express-validator";

const optional = { nullable: true, checkFalsy: true } as const;

export const proposalIdParamValidator = [
  param("id").isUUID().withMessage("El id de la propuesta debe ser un UUID válido"),
];

export const proposalResponseIdParamValidator = [
  param("responseId")
    .isUUID()
    .withMessage("El responseId debe ser un UUID válido"),
];

export const saveProposalValidator = [
  body("responseId")
    .optional(optional)
    .isUUID()
    .withMessage("responseId debe ser un UUID válido"),
  body("total")
    .optional(optional)
    .isDecimal({ decimal_digits: "0,2" })
    .withMessage("total debe ser un número con máximo 2 decimales")
    .custom((value) => Math.abs(Number(value)) < 1_000_000_000_000)
    .withMessage("total excede el máximo permitido"),
  body("totalType")
    .optional(optional)
    .isInt()
    .withMessage("totalType debe ser un entero"),
  body("statusId")
    .optional(optional)
    .isInt()
    .withMessage("statusId debe ser un entero"),
  body("showParty")
    .optional({ nullable: true })
    .isBoolean({ strict: true })
    .withMessage("showParty debe ser booleano"),
  body("notes")
    .optional({ nullable: true })
    .isString()
    .withMessage("notes debe ser texto")
    .isLength({ max: 500 })
    .withMessage("notes no puede exceder 500 caracteres"),
  body("gralPartyNumber")
    .optional(optional)
    .isInt({ min: 0 })
    .withMessage("gralPartyNumber debe ser un entero mayor o igual a 0"),
  body("gralPartyChildren")
    .optional(optional)
    .isInt({ min: 0 })
    .withMessage("gralPartyChildren debe ser un entero mayor o igual a 0"),

  body("users")
    .optional({ nullable: true })
    .isArray()
    .withMessage("users debe ser un arreglo"),
  body("users.*").isUUID().withMessage("Cada elemento de users debe ser un UUID válido"),
  body("users")
    .optional({ nullable: true })
    .custom((users: string[]) => new Set(users).size === users.length)
    .withMessage("users no puede contener ids repetidos"),

  body("products")
    .optional({ nullable: true })
    .isArray()
    .withMessage("products debe ser un arreglo"),
  body("products.*.productId")
    .optional(optional)
    .isUUID()
    .withMessage("productId debe ser un UUID válido"),
  body("products.*.addAdditionalInfo")
    .optional({ nullable: true })
    .isBoolean({ strict: true })
    .withMessage("addAdditionalInfo debe ser booleano"),
  body("products.*.fromDate")
    .optional(optional)
    .isISO8601({ strict: true, strictSeparator: true })
    .withMessage("fromDate debe tener formato YYYY-MM-DD"),
  body("products.*.toDate")
    .optional(optional)
    .isISO8601({ strict: true, strictSeparator: true })
    .withMessage("toDate debe tener formato YYYY-MM-DD"),
  body("products.*.date")
    .optional(optional)
    .isISO8601({ strict: true, strictSeparator: true })
    .withMessage("date debe tener formato YYYY-MM-DD"),
  body("products.*.newParty")
    .optional({ nullable: true })
    .isBoolean({ strict: true })
    .withMessage("newParty debe ser booleano"),
  body("products.*.showNotes")
    .optional({ nullable: true })
    .isBoolean({ strict: true })
    .withMessage("showNotes debe ser booleano"),
  body("products.*.notes")
    .optional({ nullable: true })
    .isString()
    .withMessage("Las notas del producto deben ser texto")
    .isLength({ max: 500 })
    .withMessage("Las notas del producto no pueden exceder 500 caracteres"),
  body("products.*.party")
    .optional({ nullable: true })
    .isArray()
    .withMessage("party del producto debe ser un arreglo"),

  body("party")
    .optional({ nullable: true })
    .isArray()
    .withMessage("party debe ser un arreglo"),

  ...partyMemberValidators("party.*"),
  ...partyMemberValidators("products.*.party.*"),
];

function partyMemberValidators(path: string) {
  return [
    body(`${path}.userId`)
      .optional(optional)
      .isUUID()
      .withMessage("userId de party debe ser un UUID válido"),
    body(`${path}.lastName`)
      .optional({ nullable: true })
      .isString()
      .withMessage("lastName debe ser texto")
      .isLength({ max: 50 })
      .withMessage("lastName no puede exceder 50 caracteres"),
    body(`${path}.name`)
      .optional({ nullable: true })
      .isString()
      .withMessage("name debe ser texto")
      .isLength({ max: 50 })
      .withMessage("name no puede exceder 50 caracteres"),
    body(`${path}.dob`)
      .optional(optional)
      .isISO8601({ strict: true, strictSeparator: true })
      .withMessage("dob debe tener formato YYYY-MM-DD"),
  ];
}
