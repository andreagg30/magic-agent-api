import { body, param } from "express-validator";

export const courseIdParamValidator = [
  param("id").isUUID().withMessage("El id del curso debe ser un UUID válido"),
];

export const saveCourseValidator = [
  body("title")
    .isString()
    .withMessage("title debe ser texto")
    .bail()
    .trim()
    .notEmpty()
    .withMessage("title es obligatorio"),
  body("description")
    .isString()
    .withMessage("description debe ser texto"),
  body("image")
    .optional({ nullable: true })
    .isString()
    .withMessage("image debe ser texto"),
  body("isActive")
    .isBoolean({ strict: true })
    .withMessage("isActive debe ser booleano"),
  body("modules")
    .isArray()
    .withMessage("modules debe ser un arreglo"),
  body("modules.*")
    .isObject()
    .withMessage("Cada module debe ser un objeto"),
  body("modules.*.title")
    .isString()
    .withMessage("title del módulo debe ser texto")
    .bail()
    .trim()
    .notEmpty()
    .withMessage("title del módulo es obligatorio")
    .isLength({ max: 50 })
    .withMessage("title del módulo no puede exceder 50 caracteres"),
  body("modules.*.lessons")
    .isArray()
    .withMessage("lessons debe ser un arreglo"),
  body("modules.*.lessons.*")
    .isObject()
    .withMessage("Cada lesson debe ser un objeto"),
  body("modules.*.lessons.*.title")
    .isString()
    .withMessage("title de la lección debe ser texto")
    .bail()
    .trim()
    .notEmpty()
    .withMessage("title de la lección es obligatorio")
    .isLength({ max: 50 })
    .withMessage("title de la lección no puede exceder 50 caracteres"),
  body("modules.*.lessons.*.description")
    .isString()
    .withMessage("description de la lección debe ser texto")
    .bail()
    .isLength({ max: 400 })
    .withMessage("description de la lección no puede exceder 400 caracteres"),
  body("modules.*.lessons.*.type")
    .custom((value) => value === null || (
      typeof value === "object" && value !== null &&
      Number.isInteger(value.value) && value.value > 0
    ))
    .withMessage("type debe ser null o un objeto con value válido"),
  body("modules.*.lessons.*.index")
    .optional({ nullable: true })
    .isInt({ min: 0 })
    .withMessage("index debe ser un entero mayor o igual a 0"),
  body("modules.*.lessons.*.youTubeUrl")
    .optional({ nullable: true })
    .isString()
    .withMessage("youTubeUrl debe ser texto"),
  body("modules.*.lessons.*.fileUrl")
    .optional({ nullable: true })
    .isString()
    .withMessage("fileUrl debe ser texto"),
  body("modules.*.lessons.*.blog")
    .optional({ nullable: true })
    .isArray()
    .withMessage("blog debe ser un arreglo"),
  body("modules.*.lessons.*.blog.*.type")
    .isObject()
    .withMessage("type del contenido debe ser un objeto"),
  body("modules.*.lessons.*.blog.*.type.value")
    .isInt({ min: 1 })
    .withMessage("type.value del contenido debe ser un id válido"),
  body("modules.*.lessons.*.blog.*.title")
    .optional({ nullable: true })
    .isString()
    .withMessage("title del contenido debe ser texto")
    .bail()
    .isLength({ max: 100 })
    .withMessage("title del contenido no puede exceder 100 caracteres"),
  body("modules.*.lessons.*.blog.*.buttonText")
    .optional({ nullable: true })
    .isString()
    .withMessage("buttonText del contenido debe ser texto")
    .bail()
    .isLength({ max: 60 })
    .withMessage("buttonText del contenido no puede exceder 60 caracteres"),
  body("modules.*.lessons.*.blog.*.goTo")
    .optional({ nullable: true })
    .isString()
    .withMessage("goTo del contenido debe ser texto"),
  body("modules.*.lessons.*.blog.*.description")
    .optional({ nullable: true })
    .isString()
    .withMessage("description del contenido debe ser texto"),
  body("modules.*.lessons.*.blog.*.image")
    .optional({ nullable: true })
    .isString()
    .withMessage("image del contenido debe ser texto"),
  body("modules.*.lessons.*.blog.*.imageAttributes")
    .optional({ nullable: true })
    .isObject()
    .withMessage("imageAttributes debe ser un objeto"),
  body("modules.*.lessons.*.blog.*.imageAttributes.width")
    .optional({ nullable: true })
    .isNumeric()
    .withMessage("imageAttributes.width debe ser numérico"),
  body("modules.*.lessons.*.blog.*.imageAttributes.height")
    .optional({ nullable: true })
    .isNumeric()
    .withMessage("imageAttributes.height debe ser numérico"),
  body("modules.*.lessons.*.blog.*.imageDirection")
    .optional({ nullable: true })
    .isObject()
    .withMessage("imageDirection debe ser un objeto"),
  body("modules.*.lessons.*.blog.*.imageDirection.value")
    .optional({ nullable: true })
    .isInt({ min: 1 })
    .withMessage("imageDirection.value debe ser un id válido"),
  body("modules.*.lessons.*.blog.*.index")
    .optional({ nullable: true })
    .isInt({ min: 0 })
    .withMessage("index del contenido debe ser un entero mayor o igual a 0"),
  body("products")
    .optional({ nullable: true })
    .isArray()
    .withMessage("products debe ser un arreglo")
    .bail()
    .custom((products: Array<{ id?: string }>) => {
      const ids = products.map((product) => product?.id);
      return new Set(ids).size === ids.length;
    })
    .withMessage("products no puede contener ids repetidos"),
  body("products.*")
    .isObject()
    .withMessage("Cada product debe ser un objeto"),
  body("products.*.id")
    .isUUID()
    .withMessage("Cada product debe incluir un id UUID válido"),
];
