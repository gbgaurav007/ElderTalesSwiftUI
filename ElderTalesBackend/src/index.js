import dotenv from "dotenv";
import connectDB from "./db/index.js";
import { app } from "./app.js";
import { createServer } from "http";
import { Server } from "socket.io";

dotenv.config({
  path: "./.env",
});

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("startLive", (data) => {
    console.log(`${data.username} started a live session`);
    socket.broadcast.emit("liveStarted", data);
  });

  socket.on("streamData", (data) => {
    socket.broadcast.emit("streamData", data);
  });

  socket.on("endLive", (data) => {
    console.log(`${data.username} ended the live session`);
    socket.broadcast.emit("liveEnded", { userId: socket.id });
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});


connectDB()
  .then(() => {
    httpServer.listen(process.env.PORT || 8000, () => {
      console.log(`server is running at port: ${process.env.PORT}`);
    });
  })
  .catch((err) => {
    console.log("MONGO db connection failed !!! ", err);
  });