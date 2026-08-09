import { randomUUID } from "crypto";
import { type Buffer as BufferType } from "buffer";

const CRM_BASE_URL =
  process.env.CRM_BASE_URL || "https://app.agil-travel.com";

interface ParsedBase64Image {
  buffer: Buffer;
  mimeType: string;
}

function parseBase64Image(base64: string): ParsedBase64Image {
  /*
   * Acepta:
   * data:image/png;base64,iVBORw0...
   *
   * También acepta Base64 sin prefijo.
   */
  const dataUrlMatch = base64.match(
    /^data:([^;]+);base64,(.+)$/s,
  );

  const mimeType =
    dataUrlMatch?.[1] ?? "application/octet-stream";

  const rawBase64 = dataUrlMatch?.[2] ?? base64;

  const normalizedBase64 = rawBase64
    .replace(/\s/g, "")
    .trim();

  if (!normalizedBase64) {
    throw new Error("The Base64 image is empty");
  }

  const buffer = Buffer.from(normalizedBase64, "base64");

  if (!buffer.length) {
    throw new Error("Could not convert the Base64 image to a Buffer");
  }

  return {
    buffer,
    mimeType,
  };
}

function buildMultipartBody(
  fieldName: string,
  filename: string,
  fileBuffer: BufferType,
  mimeType: string,
) {
  const boundary = `----MagicBoundary${randomUUID()}`;

  const header = Buffer.from(
    [
      `--${boundary}`,
      `Content-Disposition: form-data; name="${fieldName}"; filename="${filename}"`,
      `Content-Type: ${mimeType}`,
      "",
      "",
    ].join("\r\n"),
    "utf8",
  );

  const footer = Buffer.from(
    `\r\n--${boundary}--\r\n`,
    "utf8",
  );

  return {
    body: Buffer.concat([header, fileBuffer, footer]),
    boundary,
  };
}

async function uploadImageToCrm({
  folder,
  filename,
  fileBuffer,
  mimeType = "application/octet-stream",
}: {
  folder: string;
  filename: string;
  fileBuffer: Buffer;
  mimeType?: string;
}) {
  const fetchFn = globalThis.fetch;

  if (typeof fetchFn !== "function") {
    throw new Error("Fetch is not available in this runtime");
  }

  const url = `${CRM_BASE_URL}/api/files/upload/${encodeURIComponent(
    folder,
  )}/${encodeURIComponent(filename)}`;

  const { body, boundary } = buildMultipartBody(
    "file",
    filename,
    fileBuffer,
    mimeType,
  );

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

    throw new Error(
      `CRM upload failed: ${response.status} ${response.statusText} ${text}`,
    );
  }

  return {
    path: `${CRM_BASE_URL}/api/files/${encodeURIComponent(
      folder,
    )}/${encodeURIComponent(filename)}`,
    name: filename,
  };
}

/**
 * Esta función sí recibe directamente el Base64
 * guardado en value.src.
 */
async function uploadBase64ImageToCrm({
  folder,
  filename,
  base64,
}: {
  folder: string;
  filename: string;
  base64: string;
}) {
  const { buffer, mimeType } = parseBase64Image(base64);

  return uploadImageToCrm({
    folder,
    filename,
    fileBuffer: buffer,
    mimeType,
  });
}

async function deleteFileFromCrm({
  folder,
  filename,
}: {
  folder: string;
  filename: string;
}) {
  const url = `${CRM_BASE_URL}/api/files/${encodeURIComponent(
    folder,
  )}/${encodeURIComponent(filename)}`;

  const response = await fetch(url, { method: "DELETE" });

  // El archivo ya no existe: el resultado deseado ya se cumplió.
  if (response.status === 404) return;

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(
      `CRM delete failed: ${response.status} ${response.statusText} ${text}`,
    );
  }
}

function getCrmFileLocation(fileUrl: string) {
  try {
    const baseUrl = new URL(CRM_BASE_URL);
    const parsedUrl = new URL(fileUrl, baseUrl);

    if (parsedUrl.origin !== baseUrl.origin) return null;

    const segments = parsedUrl.pathname.split("/").filter(Boolean);
    if (
      segments.length !== 4 ||
      segments[0] !== "api" ||
      segments[1] !== "files"
    ) {
      return null;
    }

    return {
      folder: decodeURIComponent(segments[2]),
      filename: decodeURIComponent(segments[3]),
    };
  } catch {
    return null;
  }
}

export default {
  uploadImageToCrm,
  uploadBase64ImageToCrm,
  deleteFileFromCrm,
  getCrmFileLocation,
};
