//
//  ProflieView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//


import SwiftUI

struct ProfileView: View {
    @State private var userProfile: UserProfiles?
    @State private var savedPosts: [Post] = []
    @State private var isLoading = true
    @State private var selectedTab = "My Posts"
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    }
                    else if let user = userProfile {
                        
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
                        
                        
                        Picker("Tabs", selection: $selectedTab) {
                            Text("My Posts").tag("My Posts")
                            Text("Saved").tag("Saved")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .onChange(of: selectedTab) {
                            if selectedTab == "Saved" {
                                viewModel.fetchSavedPosts()
                            } else if selectedTab == "My Posts" {
                                viewModel.fetchMyPosts()
                            }
                        }
                        
                        VStack {
                            if selectedTab == "My Posts" {
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
                            } else if selectedTab == "Saved" {
                                ForEach($viewModel.savedPosts) { $post in
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
                        }
                        .onAppear {
                            if selectedTab == "My Posts" {
                                viewModel.fetchMyPosts()
                            } else if selectedTab == "Saved" {
                                viewModel.fetchSavedPosts()
                            }
                        }
                    } else {
                        Text("Failed to load profile")
                    }
                }
                .onAppear {
                    fetchUserProfile()
                    viewModel.fetchFollowers()
                    viewModel.fetchFollowing()
                }
                .navigationTitle("My Profile")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func fetchUserProfile() {
        guard let url = URL(string: "\(API_BASE_URL)/auth/current-user") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                defer { isLoading = false }
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(ProfileResponse.self, from: data)
                    self.userProfile = response.data
                    
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}




