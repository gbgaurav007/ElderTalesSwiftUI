//
//  PostDetailsView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import SwiftUI
import AVKit


struct PostDetailsView: View {
    let postId: String
    @StateObject private var viewModel = PostDetailsViewModel()
    @State private var commentContent: String = ""
    @State private var navigateToProfile: Bool = false
    @State private var selectedUserId: String?
    
    var body: some View {
        VStack {
            if let post = viewModel.post {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // Header
                        HStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 30))
                                )
                            
                            VStack(alignment: .leading) {
                                NavigationLink(
                                    destination: PeopleProfileView(userId: post.userID),
                                    isActive: $navigateToProfile
                                ) {
                                    Text(post.userName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            selectedUserId = post.userID
                                            navigateToProfile = true
                                        }
                                }
                                
                                Text(post.formattedCreatedAt())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        
                        Text(post.description)
                            .font(.body)
                        
                        if let mediaURLString = post.media.first,
                           let mediaURL = URL(string: post.mediaURL),
                           !mediaURLString.isEmpty {
                            if mediaURLString.hasSuffix(".mp4") || mediaURLString.hasSuffix(".mov") {
                                VideoPlayer(player: AVPlayer(url: mediaURL))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 200)
                                    .cornerRadius(10)
                            } else {
                                AsyncImage(url: mediaURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: .infinity, maxHeight: 200)
                                            .cornerRadius(10)
                                    case .failure:
                                        Text("Failed to load media")
                                            .foregroundColor(.red)
                                    @unknown default:
                                        Text("Unknown error")
                                    }
                                }
                            }
                        } else {
                            Text("Invalid media URL")
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Button(action: {
                                viewModel.toggleLike(postId: postId)
                            }) {
                                HStack {
                                    Image(systemName: viewModel.post?.isLiked == true ? "heart.fill" : "heart")
                                    Text("\(post.likesCount)")
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Spacer()
                            Button(action: {
                                viewModel.toggleSave(postId: postId)
                            }) {
                                Image(systemName: viewModel.post?.isSaved == true ? "bookmark.fill" : "bookmark")
                            }
                            Text("Comments")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 5)
                        
                        Divider()
                        
                        HStack {
                            TextField("Write a comment...", text: $viewModel.newCommentContent)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                viewModel.addComment(postId: postId)
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(viewModel.newCommentContent.isEmpty ? .gray : .blue)
                            }
                            .disabled(viewModel.newCommentContent.isEmpty)
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Comments")
                                .font(.headline)
                            
                            if let comments = post.comments?.sorted(by: {
                                $0.createdAt > $1.createdAt
                            }), !comments.isEmpty {
                                ForEach(comments) { comment in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(comment.user.name)
                                                .font(.subheadline)
                                                .bold()
                                            Spacer()
                                            Text(comment.formattedCreatedAt())
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Text(comment.content)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 5)
                                }
                            } else {
                                Text("No comments yet.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Post Details")
        .onAppear {
            viewModel.fetchPostDetails(postId: postId)
        }
    }
}

