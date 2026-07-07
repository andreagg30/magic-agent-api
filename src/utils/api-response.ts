// utils/apiResponse.ts
import type { Response } from "express";

type SuccessResponse<T> = {
  success: true;
  message: string;
  data?: T;
};

type ErrorResponse = {
  success: false;
  message: string;
  code?: string;
  errors?: unknown;
};

export function sendSuccess<T>({
  res,
  statusCode = 200,
  message,
  data,
}: {
  res: Response;
  statusCode?: number;
  message?: string;
  data?: T;
}) {
  const response: SuccessResponse<T> = {
    success: true,
    message: message || 'Success',
    ...(data !== undefined && { data }),
  };

  return res.status(statusCode).json(response);
}

export function sendError({
  res,
  statusCode = 500,
  message= 'UnknownError',
  errors,
}: {
  res: Response;
  statusCode?: number;
  message?: string;
  errors?: unknown;
}) {
  const response: ErrorResponse = {
    success: false,
    message,
    ...(errors !== undefined && { errors }),
  };

  return res.status(statusCode).json(response);
}
