//
//  PeopleProfileView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import SwiftUI

struct PeopleProfileView: View {
    @StateObject private var viewModel = PeopleProfileViewModel()
    @State private var posts: [Post] = []
    let userId: String
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                            .padding()
                    }
                    else if let user = viewModel.userProfile {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack{
                                VStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray)
                                    
                                    Text(user.name)
                                        .fontWeight(.bold)
                                }
                                .padding(.leading)
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(viewModel.followersCount)")
                                        .font(.headline)
                                    Text("Followers")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .padding(.bottom)
                                
                                VStack {
                                    Text("\(viewModel.followingCount)")
                                        .font(.headline)
                                    Text("Following")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom,20)
                            }
                            .padding()
                            .padding(.trailing)
                            
                            // Posts
                            Text("Posts")
                                .font(.headline)
                                .padding(.leading)
                            
                            VStack{
                                    ForEach($viewModel.posts) { $post in
                                        NavigationLink(destination: PostDetailsView(postId: post.id)) {
                                            PostCard(post: $post, onToggleLike: {
                                                viewModel.toggleLike(postId: post.id)
                                            })
                                            .environmentObject(viewModel)
                                            .padding(.horizontal)
                                            .padding(.top, 10)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            .onAppear{
                                viewModel.fetchUsersPosts(userId: userId)
                            }
                        }
                    } else {
                        Text("User not found")
                            .foregroundColor(.gray)
                    }
                }
                .onAppear {
                    viewModel.fetchPeopleProfile(userId: userId)
                }
                .navigationTitle("User Profile")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
    }
}
