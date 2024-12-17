import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { Post } from "../models/post.model.js";
import { User } from "../models/user.model.js";
import { uploadOnCloudinary } from "../utils/cloudinary.js";

const handleFileUploads = async (files) => {
  const fileUrls = [];
  for (const file of files) {
    const response = await uploadOnCloudinary(file.path);
    if (response?.url) fileUrls.push(response.url);
  }
  return fileUrls;
};

const createPost = asyncHandler(async (req, res) => {
  const { description } = req.body;

  if (!description) {
    throw new ApiError(400, "All required fields must be provided.");
  }

  const fileUrls = await handleFileUploads(req.files);

  const post = await Post.create({
    description,
    media: fileUrls,
    createdBy: req.user.name,
    user: req.user,
  });

  req.user.posts.push(post._id);
  await req.user.save();

  res
    .status(201)
    .json(new ApiResponse(201, post, "Post created successfully."));
});

const getAllPosts = asyncHandler(async (req, res) => {
  const posts = await Post.find({ _id: { $in: req.user.posts } })
    .populate("user", "name email")
    .select("description media likes comments user createdAt updatedAt")
    .sort({ createdAt: -1 });

  const formattedPosts = posts.map((post) => ({
    postId: post._id,
    description: post.description,
    media: post.media,
    likesCount: post.likes.length,
    commentsCount: post.comments.length,
    user: {
      id: post.user._id,
      name: post.user.name,
      email: post.user.email,
    },
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
  }));

  res
    .status(200)
    .json(new ApiResponse(200, formattedPosts, "Posts fetched successfully."));
});

const getAllOtherPosts = asyncHandler(async (req, res) => {
  const posts = await Post.find({ user: { $ne: req.user._id } })
    .populate("user", "name email")
    .select("description media likes comments user createdAt updatedAt")
    .sort({ createdAt: -1 });

  const formattedPosts = posts.map((post) => ({
    postId: post._id,
    description: post.description,
    media: post.media,
    likesCount: post.likes.length,
    commentsCount: post.comments.length,
    user: {
      id: post.user._id,
      name: post.user.name,
      email: post.user.email,
    },
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
  }));

  res
    .status(200)
    .json(new ApiResponse(200, formattedPosts, "Posts fetched successfully."));
});

const getPostById = asyncHandler(async (req, res) => {
  const post = await Post.findById(req.params.postId)
    .populate("user", "name email")
    .populate("comments.user", "name email");

  if (!post) {
    return res.status(404).json(new ApiResponse(404, {}, "Post not found!"));
  }

  const postDetails = {
    postId: post._id,
    description: post.description,
    media: post.media,
    likesCount: post.likes.length,
    comments: post.comments.map((comment) => ({
      user: {
        id: comment.user._id,
        name: comment.user.name,
        email: comment.user.email,
      },
      content: comment.content,
      createdAt: comment.createdAt,
    })),
    user: {
      id: post.user._id,
      name: post.user.name,
      email: post.user.email,
    },
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
  };

  res
    .status(200)
    .json(new ApiResponse(200, postDetails, "Post fetched successfully."));
});

const updatePost = asyncHandler(async (req, res) => {
  const { description } = req.body;

  const post = await Post.findById(req.params.postId);
  if (!post) {
    return res.status(404).json(new ApiResponse(404, {}, "Post not found!"));
  }

  if (!req.user.posts.includes(post._id.toString())) {
    throw new ApiError(403, "You do not have permission to update this post.");
  }

  let updatedMedia = post.media;
  if (req.files && req.files.length > 0) {
    updatedMedia = await handleFileUploads(req.files);
  }

  const updatedItem = await Post.findByIdAndUpdate(
    req.params.postId,
    { description, media: updatedMedia },
    { new: true }
  );

  res
    .status(200)
    .json(new ApiResponse(200, updatedItem, "Post updated successfully."));
});

const deletePost = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const post = await Post.findById(postId);
  if (!post) {
    return res.status(404).json(new ApiResponse(404, {}, "Post not found!"));
  }

  if (!req.user.posts.includes(post._id.toString())) {
    throw new ApiError(403, "You do not have permission to delete this post.");
  }
  await Post.findByIdAndDelete(postId);

  await User.findByIdAndUpdate(req.user._id, {
    $pull: { posts: postId },
  });

  res.status(200).json(new ApiResponse(200, {}, "Post deleted successfully."));
});

const searchPost = asyncHandler(async (req, res) => {
  const { keyword } = req.query;

  if (!keyword) {
    return res
      .status(400)
      .json(new ApiResponse(400, {}, "Search keyword is required."));
  }

  const posts = await Post.find({
    _id: { $in: req.user.posts },
    $or: [
      { description: { $regex: keyword, $options: "i" } },
      { createdBy: { $regex: keyword, $options: "i" } },
    ],
  });

  res.status(200).json(new ApiResponse(200, posts, "Search results fetched."));
});

const createComment = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const { content } = req.body;

  if (!content) {
    throw new ApiError(400, "Comment content is required.");
  }

  const post = await Post.findById(postId);

  if (!post) {
    throw new ApiError(404, "Post not found.");
  }

  const comment = {
    user: req.user._id,
    name: req.user.name,
    content,
    createdAt: new Date(),
  };

  post.comments.push(comment);
  await post.save();

  res
    .status(201)
    .json(new ApiResponse(201, comment, "Comment added successfully."));
});

const updateComment = asyncHandler(async (req, res) => {
  const { postId, commentId } = req.params;
  const { content } = req.body;

  if (!content) {
    throw new ApiError(400, "Updated content is required.");
  }

  const post = await Post.findById(postId);
  if (!post) {
    throw new ApiError(404, "Post not found.");
  }

  const comment = post.comments.id(commentId);
  if (!comment) {
    throw new ApiError(404, "Comment not found.");
  }

  if (comment.user.toString() !== req.user._id.toString()) {
    throw new ApiError(
      403,
      "You do not have permission to update this comment."
    );
  }

  comment.content = content;
  await post.save();

  res
    .status(200)
    .json(new ApiResponse(200, comment, "Comment updated successfully."));
});

const deleteComment = asyncHandler(async (req, res) => {
  const { postId, commentId } = req.params;

  const post = await Post.findById(postId);
  if (!post) {
    throw new ApiError(404, "Post not found.");
  }

  const comment = post.comments.id(commentId);
  if (!comment) {
    throw new ApiError(404, "Comment not found.");
  }

  if (comment.user.toString() !== req.user._id.toString()) {
    throw new ApiError(
      403,
      "You do not have permission to delete this comment."
    );
  }

  post.comments.pull({ _id: commentId });
  await post.save();

  res
    .status(200)
    .json(new ApiResponse(200, {}, "Comment deleted successfully."));
});

const toggleLikePost = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const userId = req.user._id;

  const post = await Post.findById(postId);

  if (!post) throw new ApiError(404, "Post not found.");

  // Toggle Like
  const userIndex = post.likes.indexOf(userId);
  if (userIndex === -1) {
    post.likes.push(userId); // Like the post
  } else {
    post.likes.splice(userIndex, 1); // Unlike the post
  }
  const isLiked = post.likes.includes(userId);
  const likesCount = post.likes.length;
  post.likesCount = likesCount;
  await post.save();

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        { likesCount: likesCount, isLiked: isLiked },
        "Post updated."
      )
    );
});

const savePost = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const userId = req.user._id;

  const user = await User.findById(userId);

  if (user.savedPosts.includes(postId)) {
    throw new ApiError(400, "Video is already saved");
  }

  user.savedPosts.push(postId);
  await user.save();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Video saved successfully"));
});

const unsavePost = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const userId = req.user._id;

  const user = await User.findById(userId);

  user.savedPosts = user.savedPosts.filter(
    (savedPostId) => savedPostId.toString() !== postId
  );

  await user.save();

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Video unsaved successfully"));
});

const getSavedPost = asyncHandler(async (req, res) => {
  const posts = await Post.find({ _id: { $in: req.user.savedPosts } })
  .populate("user", "name email")
  .select("description media likes comments user createdAt updatedAt")
  .sort({ createdAt: -1 });

const formattedPosts = posts.map((post) => ({
  postId: post._id,
  description: post.description,
  media: post.media,
  likesCount: post.likes.length,
  commentsCount: post.comments.length,
  user: {
    id: post.user._id,
    name: post.user.name,
    email: post.user.email,
  },
  createdAt: post.createdAt,
  updatedAt: post.updatedAt,
}));

res
  .status(200)
  .json(new ApiResponse(200, formattedPosts, "Posts fetched successfully."));

});

const getUsersPost = asyncHandler(async (req, res) => {
  const { userId } = req.params;

  // Validate if userId is provided
  if (!userId) {
    throw new ApiError(400, "User ID is required.");
  }

  // Fetch posts of the user
  const posts = await Post.find({ user: userId })
    .populate("user", "name email")
    .select("description media likes comments user createdAt updatedAt")
    .sort({ createdAt: -1 });

  if (!posts.length) {
    return res
      .status(404)
      .json(new ApiResponse(404, [], "No posts found for this user."));
  }

  // Format posts for the response
  const formattedPosts = posts.map((post) => ({
    postId: post._id,
    description: post.description,
    media: post.media,
    likesCount: post.likes.length,
    commentsCount: post.comments.length,
    user: {
      id: post.user._id,
      name: post.user.name,
      email: post.user.email,
    },
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
  }));

  res
    .status(200)
    .json(new ApiResponse(200, formattedPosts, "User's posts fetched successfully."));
});

export {
  createPost,
  getAllPosts,
  getAllOtherPosts,
  getPostById,
  updatePost,
  deletePost,
  searchPost,
  createComment,
  updateComment,
  deleteComment,
  toggleLikePost,
  getSavedPost,
  savePost,
  unsavePost,
  getUsersPost,
};
