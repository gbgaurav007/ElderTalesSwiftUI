import { Router } from "express";
import {
  loginUser,
  registerUser,
  logoutUser,
  refreshAccessToken,
  changeCurrentPassword,
  getCurrentUser,
  followUser,
  unfollowUser,
  getFollowers,
  getFollowing,
  getUserById,
} from "../controllers/User.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";

const userRouter = Router();

userRouter.route("/register").post(registerUser);
userRouter.route("/login").post(loginUser);
userRouter.route("/logout").post(verifyJWT, logoutUser);
userRouter.route("/refresh-token").post(refreshAccessToken);
userRouter.route("/change-password").post(verifyJWT, changeCurrentPassword);
userRouter.route("/current-user").get(verifyJWT, getCurrentUser);

userRouter.route("/:id/follow").post(verifyJWT, followUser); 
userRouter.route("/:id/unfollow").post(verifyJWT, unfollowUser);
userRouter.route("/followers").get(verifyJWT, getFollowers);
userRouter.route("/following").get(verifyJWT, getFollowing);

userRouter.route("/user/:id").get(verifyJWT, getUserById);

export default userRouter;
