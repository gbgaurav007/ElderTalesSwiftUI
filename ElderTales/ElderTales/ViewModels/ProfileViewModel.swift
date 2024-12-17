//
//  ProfileViewModel.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import Foundation


class ProfileViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var savedPosts: [Post] = []
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    
    func fetchMyPosts() {
        guard let url = URL(string: "\(API_BASE_URL)/post/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("Access Token: \(getAccessToken())")
        
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received.")
                return
            }
            print("Raw JSON: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.posts = apiResponse.data
                }
            } catch {
                print("Error decoding posts: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchSavedPosts() {
        guard let url = URL(string: "\(API_BASE_URL)/post/saved/save") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("Access Token: \(getAccessToken())")
        
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching saved posts: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received.")
                return
            }
            print("Raw JSON: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                print("Decoded Saved Response: \(apiResponse)")
                DispatchQueue.main.async {
                    self.savedPosts = apiResponse.data
                }
            } catch {
                print("Error decoding posts: \(error.localizedDescription)")
            }
        }.resume()
        print("Saved Posts Count: \(self.savedPosts.count)")
    }
    
    func fetchFollowers() {
        guard let url = URL(string: "\(API_BASE_URL)/followers") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(FollowersFollowingResponse.self, from: data)
                DispatchQueue.main.async {
                    self.followersCount = response.data.followersCount ?? 0
                }
            } catch {
                print("Error decoding followers: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchFollowing() {
        guard let url = URL(string: "\(API_BASE_URL)/following") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching following: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(FollowersFollowingResponse.self, from: data)
                DispatchQueue.main.async {
                    self.followingCount = response.data.followingCount ?? 0
                }
            } catch {
                print("Error decoding following: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func toggleLike(postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        PostService.shared.toggleLike(postId: postId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let likeData):
                    self.posts[index].isLiked = likeData.isLiked
                    self.posts[index].likesCount = likeData.likesCount
                case .failure(let error):
                    print("Error toggling like: \(error.localizedDescription)")
                }
            }
        }
    }
}
