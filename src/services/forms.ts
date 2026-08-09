import { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";
import crmService from "./crm.js";

type FormPayload = Record<string, any>;

function getQuestionImageUrl(question: Record<string, any>) {
  if (!question.image || typeof question.image !== "object") {
    return typeof question.path === "string" ? question.path : null;
  }

  const url = question.image.src ?? question.image.path ?? question.path;
  return typeof url === "string" && url ? url : null;
}

function collectImageUrls(payload: FormPayload) {
  const urls = new Set<string>();
  const sections = Array.isArray(payload.sections) ? payload.sections : [];

  for (const section of sections) {
    const questions = Array.isArray(section?.questions) ? section.questions : [];
    for (const question of questions) {
      if (!question || typeof question !== "object") continue;
      const url = getQuestionImageUrl(question);
      if (url) urls.add(url);
    }
  }

  return urls;
}

const saveForm = async ({
  payload,
  images,
  client,
  updateFormId,
}: {
  payload: FormPayload;
  images: Express.Multer.File[];
  client: PoolClient;
  updateFormId?: string;
}) => {
  const sections = Array.isArray(payload.sections) ? payload.sections : [];
  const imagesByBlockId = new Map(images.map((file) => [file.originalname, file]));

  for (const section of sections) {
    if (!section || typeof section !== "object") continue;
    const questions = Array.isArray(section.questions) ? section.questions : [];

    for (const question of questions) {
      if (
        question &&
        typeof question === "object" &&
        question.addImage &&
        question.image &&
        typeof question.image === "object"
      ) {
        const image = question.image as {
          blockId?: string;
          src?: string;
          path?: string;
          name?: string;
          caption?: string;
          alt?: string;
        };
        const imageName = image.name || image.caption || image.alt;
        const file = image.blockId ? imagesByBlockId.get(image.blockId) : undefined;

        if (file && imageName) {
          const uploadFolder = "forms";
          const safeName = imageName.replace(/[^a-zA-Z0-9._-]/g, "_");
          const filename = `${Date.now()}-${safeName}`;
          const uploaded = await crmService.uploadImageToCrm({
            folder: uploadFolder,
            filename,
            fileBuffer: file.buffer,
            mimeType: file.mimetype,
          });

          image.src = uploaded.path;
          image.name = uploaded.name;
          imagesByBlockId.delete(image.blockId!);
        } else if (!image.src && !image.path) {
          throw new Error(`No se recibió el archivo de la imagen ${image.blockId ?? "sin blockId"}`);
        }
      }
    }
  }

  if (imagesByBlockId.size) {
    throw new Error("Se recibieron imágenes que no pertenecen al formulario");
  }

  const result = updateFormId
    ? await client.query(
        `SELECT update_form_payload($1::uuid, $2::jsonb) AS form_id`,
        [updateFormId, payload],
      )
    : await client.query(
        `SELECT save_form_payload($1::jsonb) AS form_id`,
        [payload],
      );

  return result.rows[0]?.form_id;
};

const updateForm = async ({
  formId,
  payload,
  images,
  client,
}: {
  formId: string;
  payload: FormPayload;
  images: Express.Multer.File[];
  client: PoolClient;
}) => {
  const currentResult = await client.query(
    `SELECT get_form_payload($1::uuid) AS payload`,
    [formId],
  );
  const currentPayload = currentResult.rows[0]?.payload;

  if (!currentPayload) return null;

  const previousImageUrls = collectImageUrls(currentPayload);
  const updatedFormId = await saveForm({
    payload: { ...payload, id: formId },
    images,
    client,
    updateFormId: formId,
  });
  const nextImageUrls = collectImageUrls(payload);
  const obsoleteImageUrls = [...previousImageUrls].filter(
    (url) => !nextImageUrls.has(url),
  );

  return { formId: updatedFormId, obsoleteImageUrls };
};

const deleteObsoleteFormImages = async (imageUrls: string[]) => {
  const deletions = imageUrls.map(async (imageUrl) => {
    const location = crmService.getCrmFileLocation(imageUrl);
    if (!location || location.folder !== "forms") return;
    await crmService.deleteFileFromCrm(location);
  });

  return Promise.allSettled(deletions);
};

const getForms = async () => {
  const result = await pool.query(`SELECT * FROM get_forms_list()`);
  return result.rows;
};

const getFormById = async ({ formId }: { formId: string }) => {
  const result = await pool.query(
    `SELECT get_form_payload($1::uuid) AS payload`,
    [formId],
  );

  return result.rows[0]?.payload;
};

const deleteForm = async ({ formId, client }: { formId: string; client: PoolClient }) => {
  await client.query(`SELECT delete_form($1::uuid)`, [formId]);
};

export default {
  saveForm,
  updateForm,
  deleteObsoleteFormImages,
  getForms,
  getFormById,
  deleteForm,
};
