import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { Post } from "../models/post.model.js";
import { User } from "../models/user.model.js";
import { uploadOnCloudinary } from "../utils/cloudinary.js";
import fs from "fs";


const handleImageUploads = async (files) => {
  const imageUrls = [];
  for (const file of files) {
    const response = await uploadOnCloudinary(file.path);
    if (response?.url) imageUrls.push(response.url);
  }
  return imageUrls;
};


const createPost = asyncHandler(async (req, res) => {

  const { description } = req.body;

  if (!description) {
    throw new ApiError(400, "All required fields must be provided.");
  }
  
  const imageUrls = await handleImageUploads(req.files);

  const post = await Post.create({
    description,
    images: imageUrls,
  });

  req.user.posts.push(post._id);
  await req.user.save();

  res.status(201).json(new ApiResponse(201, post, "Post created successfully."));
});


const getAllPosts = asyncHandler(async (req, res) => {
  const posts = await Post.find({ _id: { $in: req.user.posts } });
  res.status(200).json(new ApiResponse(200, posts, "Posts fetched successfully."));
});


const getPostById = asyncHandler(async (req, res) => {
  const post = await Post.findById(req.params.postId);
  if (!post) {
    return res
    .status(404)
    .json(new ApiResponse(404, {}, "Post not found!"));
  }
  res.status(200).json(new ApiResponse(200, post, "Post fetched successfully."));
});


const updatePost = asyncHandler(async (req, res) => {
  const { description } = req.body;

  const post = await Post.findById(req.params.postId);
  if (!post) {
    return res
    .status(404)
    .json(new ApiResponse(404, {}, "Post not found!"));
  }

  if (!req.user.posts.includes(post._id.toString())) {
    throw new ApiError(403, "You do not have permission to update this post.");
  }

  let updatedImages = post.images;
  if (req.files && req.files.length > 0) {
    updatedImages = await handleImageUploads(req.files);
  }

  const updatedItem = await Post.findByIdAndUpdate(req.params.postId, req.body, updatedImages, { new: true });

  res.status(200).json(new ApiResponse(200, updatedItem, "post updated successfully."));
});


const deletePost = asyncHandler(async (req, res) => {

  const {postId} = req.params;
  const post = await Post.findById(postId);
  if (!post) {
    return res
    .status(404)
    .json(new ApiResponse(404, {}, "Post not found!"));
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
      { title: { $regex: keyword, $options: "i" } },
      { description: { $regex: keyword, $options: "i" } }
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
    user: req.user._id, // Assuming `req.user` contains the authenticated user's details
    content,
    createdAt: new Date(),
  };

  post.comments.push(comment);
  await post.save();

  res.status(201).json(new ApiResponse(201, comment, "Comment added successfully."));
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
    throw new ApiError(403, "You do not have permission to update this comment.");
  }

  comment.content = content;
  await post.save();

  res.status(200).json(new ApiResponse(200, comment, "Comment updated successfully."));
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
    throw new ApiError(403, "You do not have permission to delete this comment.");
  }

  comment.remove();
  await post.save();

  res.status(200).json(new ApiResponse(200, {}, "Comment deleted successfully."));
});

export { createPost, getAllPosts, getPostById, updatePost, deletePost, searchPost, createComment , updateComment, deleteComment};