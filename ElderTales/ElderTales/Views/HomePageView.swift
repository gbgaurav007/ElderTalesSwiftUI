//
//  HomePageView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = PostViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                ScrollView {
                    ForEach($viewModel.posts) { $post in
                        NavigationLink(destination: PostDetailsView(postId: post.id)) {
                            PostCard(post: $post, onToggleLike:{
                                viewModel.toggleLike(postId: post.id)
                            },
                                     onToggleSave: {
                                viewModel.toggleSave(postId: post.id)
                            })
                                .environmentObject(viewModel)
                                .padding(.horizontal)
                                .padding(.top, 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .onAppear {
                viewModel.fetchPosts()
            }
            .navigationTitle("Home")
        }
    }
}
