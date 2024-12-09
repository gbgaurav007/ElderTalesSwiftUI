import mongoose, { Schema } from "mongoose";

const commentSchema = new Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    name: {
      type: String,
    },
    content: {
      type: String,
      required: true,
      trim: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

const postSchema = new Schema(
  {
    description: {
      type: String,
      trim: true,
    },
    createdBy: {
      type: String
    },
    media: {
      type: [String],
      validate: {
        validator: function (v) {
          return v.length <= 10;
        },
        message: 'A post can have a maximum of 10 images.',
      },
    },
    likesCount: {
      type: Number,
      default: 0
    },
    likes: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: "User",
      default: [],
    },
    comments: [commentSchema], 
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
  },
  { timestamps: true }
);

export const Post = mongoose.model("Post", postSchema);