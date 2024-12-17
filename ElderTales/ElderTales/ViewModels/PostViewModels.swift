//
//  PostViewModels.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var post: Post?
    
    func fetchPosts() {
        guard let url = URL(string: "\(API_BASE_URL)/post/getAllOtherPosts") else { return }
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
    
    func toggleSave(postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        let isCurrentlySaved = posts[index].isSaved
        PostService.shared.toggleSave(postId: postId, isSaved: isCurrentlySaved) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.posts[index].isSaved.toggle()
                case .failure(let error):
                    print("Error toggling save: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func toggleFollow(userId: String) {
        guard let index = posts.firstIndex(where: { $0.userID == userId }) else { return }
        let isCurrentlyFollowing = posts[index].isFollowing
        
        PostService.shared.toggleFollow(userId: userId, isFollowing: isCurrentlyFollowing) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.posts[index].isFollowing.toggle()
                case .failure(let error):
                    print("Error toggling follow: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
