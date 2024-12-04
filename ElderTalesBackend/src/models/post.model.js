import mongoose, { Schema } from "mongoose";

const commentSchema = new Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
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
  { _id: false }
);

const postSchema = new Schema(
  {
    description: {
      type: String,
      trim: true,
    },
    images: {
      type: [String],
      validate: {
        validator: function (v) {
          return v.length <= 10;
        },
        message: 'A post can have a maximum of 10 images.',
      },
    },
    likes: {
      type: Number,
      default: 0,
    },
    comments: [commentSchema], 
  },
  { timestamps: true }
);

export const Post = mongoose.model("Post", postSchema);