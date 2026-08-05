import { PoolClient } from "pg";
import { pool } from "../database/db-connection.js";
import crmService from "./crm.js";

const saveForm = async ({
  payload,
  client,
}: {
  payload: Record<string, unknown>;
  client: PoolClient;
}) => {
  const sections = Array.isArray(payload.sections) ? payload.sections : [];

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
        const image = question.image as { src?: string; name?: string; caption?: string; alt?: string };
        const imageSrc = image.src;
        const imageName = image.name || image.caption || image.alt;
console.log('entra?');

        if (typeof imageSrc === "string" && imageSrc.startsWith("blob:") && imageName) {
          const blobData = await fetch(imageSrc);
          console.log(blobData, 'blobDatablobDatablobDatablobData');
          
          if (!blobData.ok) {
            throw new Error(`No se pudo descargar la imagen local: ${imageSrc}`);
          }

          const buffer = Buffer.from(await blobData.arrayBuffer());
          const uploadFolder = "forms";
          const filename = `${Date.now()}-${imageName}`;
          const uploaded = await crmService.uploadImageToCrm({
            folder: uploadFolder,
            filename,
            fileBuffer: buffer,
          });

          question.path = uploaded.path;
          question.name = uploaded.name;
          delete question.image;
        }
      }
    }
  }

  const result = await client.query(
    `SELECT save_form_payload($1::jsonb) AS form_id`,
    [payload],
  );

  return result.rows[0]?.form_id;
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
  getForms,
  getFormById,
  deleteForm,
};
