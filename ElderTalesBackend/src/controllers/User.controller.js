import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.model.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import jwt, { decode } from "jsonwebtoken";

const generateAccessAndRefreshTokens = async (userId) => {
  try {
    const user = await User.findById(userId);
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });

    return { accessToken, refreshToken };
  } catch (error) {
    throw new ApiError(
      500,
      "Something went wrong while generating referesh and access token"
    );
  }
};

const registerUser = asyncHandler(async (req, res) => {
  try {
    const { name, contact, age, email, password } = req.body;

    if (!name || !contact || !age || !email || !password) {
      return res
        .status(400)
        .json(new ApiResponse(400, {}, "All fields are required."));
    }

    const existedUser = await User.findOne({ email });

    if (existedUser) {
      //throw new ApiError(409, "User with email already exists.");
      return res
        .status(409)
        .json(new ApiResponse(409, {}, "User with email already exists."));
    }

    const user = await User.create({
      name,
      contact,
      age,
      email,
      password,
    });

    const createdUser = await User.findById(user._id).select(
      "-password -refreshToken"
    );
    if (!createdUser) {
      throw new ApiError(
        500,
        "Something went wrong while registering the user"
      );
    }
    return res
      .status(201)
      .json(new ApiResponse(201, createdUser, "User registered Sucessfully"));
  } catch (error) {
    console.error("Error registering user:", error);
    throw new ApiError(401, error?.message || "Problem Registering User");
  }
});

const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email) {
    throw new ApiError(400, "email is required");
  }

  const user = await User.findOne({ email });

  if (!user) {
    return res
      .status(404)
      .json(new ApiResponse(404, {}, "User does not exist"));
    // throw new ApiError(404, "user does not exist");
  }
  const isPasswordValid = await user.isPasswordCorrect(password);

  if (!isPasswordValid) {
    // throw new ApiError(401, "Invalid user credentials");
    return res
      .status(401)
      .json(new ApiResponse(401, {}, "Invalid user credentials"));
  }

  const { accessToken, refreshToken } = await generateAccessAndRefreshTokens(
    user._id
  );

  const loggedInUser = await User.findById(user._id).select(
    "-password -refreshToken"
  );

  const options = {
    httpOnly: true,
    secure: true,
  };
  return res
    .status(200)
    .cookie("accessToken", accessToken, options)
    .cookie("refreshToken", refreshToken, options)
    .json(
      new ApiResponse(
        200,
        {
          user: loggedInUser,
          accessToken,
          refreshToken,
        },
        "User logged in Successfully"
      )
    );
});

const logoutUser = asyncHandler(async (req, res) => {
  User.findByIdAndUpdate(
    req.user._id,
    {
      $unset: {
        refreshToken: 1,
      },
    },
    {
      new: true,
    }
  );
  const options = {
    httpOnly: true,
    secure: true,
  };
  return res
    .status(200)
    .clearCookie("accessToken", options)
    .clearCookie("refreshToken", options)
    .json(new ApiResponse(200, {}, "User Logged Out"));
});

const refreshAccessToken = asyncHandler(async (req, res) => {
  const incomingRefreshToken =
    req.cookies.refreshToken || req.body.refreshToken;

  if (!incomingRefreshToken) {
    throw new ApiError(401, "unauthorized request");
  }

  try {
    const decodedToken = jwt.verify(
      incomingRefreshToken,
      process.env.REFRESH_TOKEN_SECRET
    );

    const user = await User.findById(decodedToken?._id);

    if (!user) {
      throw new ApiError(401, "Invalid refresh token");
    }

    if (incomingRefreshToken !== user?.refreshToken) {
      throw new ApiError(401, "Refresh token is expired or used");
    }

    const options = {
      httpOnly: true,
      secure: true,
    };

    const { accessToken, newRefreshToken } =
      await generateAccessAndRefreshTokens(user._id);

    return res
      .status(200)
      .cookie("accessToken", accessToken, options)
      .cookie("refreshToken", newRefreshToken, options)
      .json(
        new ApiResponse(
          200,
          { accessToken, refreshToken: newRefreshToken },
          "Access token refreshed"
        )
      );
  } catch (error) {
    throw new ApiError(401, error?.message || "Invalid refresh token");
  }
});

const changeCurrentPassword = asyncHandler(async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  const user = await User.findById(req.user?._id);
  const isPasswordCorrect = user.isPasswordCorrect(oldPassword);

  if (!isPasswordCorrect) {
    throw new ApiError(400, "Invalid old password");
  }
  user.password = newPassword;
  await user.save({ validateBeforeSave: false });

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Password changed successfully"));
});

const getCurrentUser = asyncHandler(async (req, res) => {
  return res
    .status(200)
    .json(new ApiResponse(200, req.user, "Current user fetched successfully"));
});

const followUser = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const userId = req.user._id;

  if (userId.toString() === id) {
    throw new ApiError(400, "You cannot follow yourself");
  }

  const userToFollow = await User.findById(id);
  const currentUser = await User.findById(userId);

  if (!userToFollow) {
    throw new ApiError(404, "User to follow not found");
  }

  if (currentUser.following.includes(id)) {
    throw new ApiError(400, "You are already following this user");
  }

  currentUser.following.push(id);
  userToFollow.followers.push(userId);

  await currentUser.save();
  await userToFollow.save();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "User followed successfully"));
});

const unfollowUser = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const userId = req.user._id;

  const userToUnfollow = await User.findById(id);
  const currentUser = await User.findById(userId);

  if (!userToUnfollow) {
    throw new ApiError(404, "User to unfollow not found");
  }

  currentUser.following = currentUser.following.filter(
    (followingId) => followingId.toString() !== id
  );
  userToUnfollow.followers = userToUnfollow.followers.filter(
    (followerId) => followerId.toString() !== userId.toString()
  );

  await currentUser.save();
  await userToUnfollow.save();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "User unfollowed successfully"));
});

const getFollowers = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const user = await User.findById(userId).populate("followers", "name email");

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return res.status(200).json(
    new ApiResponse(
      200,
      {
        followersCount: user.followers.length,
        followers: user.followers,
      },
      "Followers fetched successfully"
    )
  );
});

const getFollowing = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  const user = await User.findById(userId).populate("following", "name email");

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return res.status(200).json(
    new ApiResponse(
      200,
      {
        followingCount: user.following.length,
        following: user.following,
      },
      "Following fetched successfully"
    )
  );
});

const getUserById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  // Fetch user by ID, populate followers, following, and posts
  const user = await User.findById(id)
    .select("-password -refreshToken")

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return res.status(200).json(
    new ApiResponse(
      200,
      {
        user,
        followersCount: user.followers.length,
        followingCount: user.following.length,
      },
      "User details fetched successfully"
    )
  );
});

export {
  registerUser,
  loginUser,
  logoutUser,
  refreshAccessToken,
  changeCurrentPassword,
  getCurrentUser,
  followUser,
  unfollowUser,
  getFollowers,
  getFollowing,
  getUserById,
};
