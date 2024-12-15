//
//  PostDetailsViewModel.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation

class PostDetailsViewModel: ObservableObject, LikeHandling {
    @Published var post: Post?
    @Published var likesCount: Int = 0
    @Published var isLiked: Bool = false
    @Published var newCommentContent: String = ""
    
    func fetchPostDetails(postId: String) {
        guard let url = URL(string: "\(API_BASE_URL)/post/\(postId)") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching post details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            do {
                let response = try JSONDecoder().decode(PostDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.post = response.data
                    self.likesCount = response.data.likesCount
                    self.isLiked = response.data.isLiked
                }
            } catch {
                print("Error fetching post details: \(error)")
            }
        }.resume()
    }
    
    func toggleLike(postId: String) {
        guard let url = URL(string: "\(API_BASE_URL)/post/\(postId)/like") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "DELETE" : "POST"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error toggling like: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let response = try JSONDecoder().decode(LikeResponse.self, from: data)
                DispatchQueue.main.async {
                    self.isLiked = response.isLiked
                    self.likesCount = response.likesCount
                }
            } catch {
                print("Error decoding like response: \(error)")
            }
        }.resume()
    }
    
    func addComment(postId: String) {
        guard let url = URL(string: "\(API_BASE_URL)/post/\(postId)/comments") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let content = ["content": newCommentContent]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: content) else { return }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error adding comment: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AddCommentResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.success, self.post != nil {
                        let postComment = PostComment(
                            user: UserProfile(id: response.data.user, name: response.data.name, email: ""),
                            content: response.data.content,
                            createdAt: response.data.createdAt
                        )
                        self.post?.comments?.append(postComment)
                        self.post?.commentsCount = self.post?.comments?.count ?? 0
                        self.newCommentContent = "" // Clear the text field
                    } else {
                        print("Failed to add comment: \(response.message)")
                    }
                }
            } catch {
                print("Error decoding new comment: \(error)")
            }
        }.resume()
    }
}


protocol LikeHandling {
    var likesCount: Int { get set }
    var isLiked: Bool { get set }
    
    func toggleLike(postId: String)
}
