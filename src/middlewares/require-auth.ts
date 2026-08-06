// middlewares/requireAuth.ts
import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export type AuthRequest = Request & {
  user?: {
    userId: string;
    email: string;
  };
};

export function requireAuth(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  try {
    const accessToken = req.cookies.accessToken;

    if (!accessToken) {
      // La ausencia del access token es un estado de autenticación, no un
      // request inválido. El cliente usa el 401 para iniciar el refresh.
      return res.status(401).json({
        message: "tokenMissing",
      });
    }

    const decoded = jwt.verify(
      accessToken,
      process.env.JWT_ACCESS_SECRET as string
    ) as {
      userId: string;
      email: string;
    };

    req.user = {
      userId: decoded.userId,
      email: decoded.email,
    };

    next();
  } catch {
    return res.status(401).json({
      message: "InvalidExiredToken",
    });
  }
}
