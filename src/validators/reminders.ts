import { body, param } from "express-validator";

export const reminderIdParamValidator = [
  param("id")
    .isUUID()
    .withMessage("El id del reminder debe ser un UUID válido"),
];

export const saveReminderValidator = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("name es obligatorio")
    .isLength({ max: 50 })
    .withMessage("name no puede exceder 50 caracteres"),
  body("description")
    .optional({ nullable: true })
    .isString()
    .withMessage("description debe ser texto")
    .isLength({ max: 400 })
    .withMessage("description no puede exceder 400 caracteres"),
  body("isActive")
    .isBoolean({ strict: true })
    .withMessage("isActive debe ser booleano"),
  body("date")
    .isString()
    .withMessage("date debe ser texto")
    .isISO8601({ strict: true })
    .withMessage("date debe ser una fecha ISO 8601 válida"),
  body("urgency")
    .isInt()
    .withMessage("urgency debe ser un id entero"),
  body("reservation")
    .optional({ nullable: true })
    .isArray()
    .withMessage("reservation debe ser un arreglo"),
  body("reservation.*")
    .isUUID()
    .withMessage("Cada reservation debe ser un UUID de propuesta válido"),
  body("reservation")
    .optional({ nullable: true })
    .custom((reservation: string[]) => {
      if (new Set(reservation).size !== reservation.length) {
        throw new Error("reservation no puede contener ids repetidos");
      }
      return true;
    }),
];
