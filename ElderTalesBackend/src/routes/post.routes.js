import { Router } from "express";
import {
  createPost,
  getAllPosts,
  getPostById,
  getAllOtherPosts,
  updatePost,
  deletePost,
  searchPost,
  createComment,
  updateComment,
  deleteComment,
  toggleLikePost,
  savePost,
  unsavePost,
  getSavedPost,
  getUsersPost,
} from "../controllers/Post.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/multer.middleware.js";

const postRouter = Router();

postRouter
  .route("/")
  .post(verifyJWT, upload.array("media", 10), createPost)
  .get(verifyJWT, getAllPosts);

postRouter.route("/getAllOtherPosts").get(verifyJWT, getAllOtherPosts);

postRouter.route("/search").get(verifyJWT, searchPost);

postRouter
  .route("/:postId")
  .get(verifyJWT, getPostById)
  .put(verifyJWT, upload.array("media", 10), updatePost)
  .delete(verifyJWT, deletePost);

postRouter.route("/:postId/comments").post(verifyJWT, createComment);

postRouter
  .route("/:postId/comments/:commentId")
  .put(verifyJWT, updateComment)
  .delete(verifyJWT, deleteComment);

postRouter.route("/:postId/like").put(verifyJWT, toggleLikePost);

postRouter
  .route("/save/:postId")
  .post(verifyJWT, savePost)
  .delete(verifyJWT, unsavePost);

postRouter.route("/saved/save").get(verifyJWT, getSavedPost);

postRouter.route("/:userId/posts").get(verifyJWT, getUsersPost);

export default postRouter;
