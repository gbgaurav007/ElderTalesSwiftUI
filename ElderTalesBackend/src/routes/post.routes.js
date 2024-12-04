import { Router } from "express";
import {
  createPost,
  getAllPosts,
  getPostById,
  updatePost,
  deletePost,
  searchPosts,
  createComment,
  updateComment,
  deleteComment,
} from "../controllers/Post.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/multer.middleware.js";

const postRouter = Router();

postRouter.route("/")
  .post(verifyJWT, upload.array("images", 10), createPost)
  .get(verifyJWT, getAllPosts);

postRouter.route("/search")
  .get(verifyJWT, searchPosts);

postRouter.route("/:postId")
  .get(verifyJWT, getPostById)
  .put(verifyJWT, upload.array("images", 10), updatePost)
  .delete(verifyJWT, deletePost);

postRouter.route("/:postId/comments")
  .post(verifyJWT, createComment);

postRouter.route("/:postId/comments/:commentId")
  .put(verifyJWT, updateComment)
  .delete(verifyJWT, deleteComment); 

export default postRouter;