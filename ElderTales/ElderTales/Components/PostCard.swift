//
//  PostCard.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import SwiftUI
import AVKit

struct PostCard: View {
    @Binding var post: Post
    @EnvironmentObject var viewModel: PostViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
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
                    Text(post.userName)
                        .font(.headline)
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
                    viewModel.toggleLike(postId: post.id)
                }) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    Text("\(post.likesCount)")
                }
                Button(action: {}) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("\(post.commentsCount)")
                    }
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.down")
                        .padding()
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
    }
}
