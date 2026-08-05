import { randomUUID } from "crypto";
import { type Buffer as BufferType } from "buffer";

const CRM_BASE_URL = process.env.CRM_BASE_URL || "https://app.agil-travel.com";

function buildMultipartBody(fieldName: string, filename: string, fileBuffer: BufferType) {
  const boundary = `----MagicBoundary${randomUUID()}`;
  const header = Buffer.from(
    `--${boundary}\r\nContent-Disposition: form-data; name="${fieldName}"; filename="${filename}"\r\nContent-Type: application/octet-stream\r\n\r\n`,
    "utf8",
  );
  const footer = Buffer.from(`\r\n--${boundary}--\r\n`, "utf8");
  return {
    body: Buffer.concat([header, fileBuffer, footer]),
    boundary,
  };
}

async function uploadImageToCrm({
  folder,
  filename,
  fileBuffer,
}: {
  folder: string;
  filename: string;
  fileBuffer: Buffer;
}) {
  const fetchFn = (globalThis as any).fetch;

  if (typeof fetchFn !== "function") {
    throw new Error("Fetch is not available in this runtime");
  }

  const url = `${CRM_BASE_URL}/api/files/upload/${encodeURIComponent(folder)}/${encodeURIComponent(
    filename,
  )}`;

  const { body, boundary } = buildMultipartBody("file", filename, fileBuffer);

  const response = await fetchFn(url, {
    method: "POST",
    headers: {
      "Content-Type": `multipart/form-data; boundary=${boundary}`,
      "Content-Length": String(body.length),
    },
    body,
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`CRM upload failed: ${response.status} ${response.statusText} ${text}`);
  }

  return {
    path: `${CRM_BASE_URL}/api/files/${encodeURIComponent(folder)}/${encodeURIComponent(filename)}`,
    name: filename,
  };
}

export default {
  uploadImageToCrm,
};
