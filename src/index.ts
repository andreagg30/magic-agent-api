import "./config/env.js";

import express, {
  type Request,
  type Response,
  type NextFunction,
} from "express";
import otpRouter from "./routes/otps.js";
import userRouter from "./routes/users.js";
import sessionRouter from "./routes/sessions.js";
import formRouter from "./routes/forms.js";
import cookieParser from "cookie-parser";
import cors from "cors";
import emailService from "./services/mails.js";
import passwordRouter from "./routes/passwords.js";
// Create the Express application
const app = express();
const port = 3000;

// Middleware to parse incoming JSON requests
app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: process.env.CLIENT_URL,
    credentials: true,
  }),
);

// Root endpoint
app.get("/", async (req: Request, res: Response) => {
  res.send({ message: "Hello World" });
});

app.post("/api/test-mail", async (req: Request, res: Response) => {
  try {
    await emailService.sendOtp({
      otp: "234233",
      email: "agg300320@hotmail.com",
    });
    res.send({ message: "Hello World" });
  } catch (error) {
    console.error(error);
  }
});

app.use("/api/users", userRouter);
app.use("/api/otp", otpRouter);
app.use("/api/sessions", sessionRouter);
app.use("/api/passwords", passwordRouter);
app.use("/api/forms", formRouter);

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err);
  res.status(500).send("Something went wrong");
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
