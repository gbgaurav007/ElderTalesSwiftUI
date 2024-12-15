import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import path from "path";

const app = express();

const corsConfig = {
  credentials: true,
  origin: true,
};

app.use(cors(corsConfig))

app.use(express.json({ limit: "'50mb'" }));
app.use(express.urlencoded({ extended: true, limit: "'50mb'" }));
app.use(express.static("public"));
app.use(cookieParser());

import userRouter from "./routes/user.routes.js";
import postRouter from "./routes/post.routes.js";

app.use("/api/auth", userRouter);
app.use("/api/post", postRouter);

app.use("/api/docs", (req, res) => {
  const filePath = path.resolve("public", "docs", "ElderTales-Docs.json");
  res.sendFile(filePath);
});

export { app };
