import { body } from "express-validator";

export const getUserValidator = [
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email required")
    .isEmail()
    .withMessage("Invalid Email")
    .isLength({ max: 255 })
    .withMessage("Email must not be longer than 255")
    .normalizeEmail(),

  body("password")
    .notEmpty()
    .withMessage("La contraseña es obligatoria")
    .isLength({ min: 8, max: 100 })
    .withMessage("La contraseña debe tener entre 8 y 100 caracteres")
    .matches(/[A-Z]/)
    .withMessage("La contraseña debe incluir al menos una mayúscula")
    .matches(/[a-z]/)
    .withMessage("La contraseña debe incluir al menos una minúscula")
    .matches(/[0-9]/)
    .withMessage("La contraseña debe incluir al menos un número"),
];

export const addUserValidator = [
  body("first_name")
    .trim()
    .notEmpty()
    .withMessage("El nombre es obligatorio")
    .isLength({ min: 2, max: 100 })
    .withMessage("El nombre debe tener entre 2 y 100 caracteres"),

  body("last_name")
    .trim()
    .notEmpty()
    .withMessage("El apellido es obligatorio")
    .isLength({ min: 2, max: 100 })
    .withMessage("El apellido debe tener entre 2 y 100 caracteres"),

  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email required")
    .isEmail()
    .withMessage("Invalid Email")
    .isLength({ max: 255 })
    .withMessage("Email must not be longer than 255")
    .normalizeEmail(),

  body("phone")
    .optional({ nullable: true, checkFalsy: true })
    .trim()
    .isLength({ max: 20 })
    .withMessage("El teléfono no debe superar 20 caracteres")
    .matches(/^[0-9+\-\s()]+$/)
    .withMessage(
      "El teléfono solo puede contener números, espacios, +, -, ( y )",
    ),

  body("password")
    .notEmpty()
    .withMessage("La contraseña es obligatoria")
    .isLength({ min: 8, max: 100 })
    .withMessage("La contraseña debe tener entre 8 y 100 caracteres")
    .matches(/[A-Z]/)
    .withMessage("La contraseña debe incluir al menos una mayúscula")
    .matches(/[a-z]/)
    .withMessage("La contraseña debe incluir al menos una minúscula")
    .matches(/[0-9]/)
    .withMessage("La contraseña debe incluir al menos un número"),
  body("email_verified")
    .optional()
    .isBoolean({ strict: true })
    .withMessage("email_verified debe ser un booleano"),
];

export const verifyOtpValidator = [
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email required")
    .isEmail()
    .withMessage("Invalid Email")
    .isLength({ max: 255 })
    .withMessage("Email must not be longer than 255")
    .normalizeEmail(),
  body("otp")
    .trim()
    .notEmpty()
    .withMessage("OTP is required")
    .isLength({ min: 6, max: 6 })
    .withMessage("OTP must be 6 digits")
    .matches(/^\d{6}$/)
    .withMessage("OTP must contain only numbers"),
];

export const changeMailOtpValidator = [
  ...getUserValidator,
  body("newEmail")
    .trim()
    .notEmpty()
    .withMessage("Email required")
    .isEmail()
    .withMessage("Invalid Email")
    .isLength({ max: 255 })
    .withMessage("Email must not be longer than 255")
    .normalizeEmail(),
];

export const forgotPasswordValidator = [
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email is required")
    .isEmail()
    .withMessage("Invalid email")
    .normalizeEmail(),
];

export const resetPasswordValidator = [
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email is required")
    .isEmail()
    .withMessage("Invalid email")
    .normalizeEmail(),

  body("otp")
    .trim()
    .notEmpty()
    .withMessage("OTP is required")
    .isLength({ min: 6, max: 6 })
    .withMessage("OTP must be 6 digits")
    .matches(/^\d{6}$/)
    .withMessage("OTP must contain only numbers"),

  body("newPassword")
    .notEmpty()
    .withMessage("New password is required")
    .isLength({ min: 8 })
    .withMessage("Password must be at least 8 characters"),
];
