//
//  PostService.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation

class PostService {
    static let shared = PostService()
    private init() {}
    
    func toggleLike(postId: String, completion: @escaping (Result<LikeData, Error>) -> Void) {
        guard let url = URL(string: "\(API_BASE_URL)/post/\(postId)/like") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(ToggleLikeResponse.self, from: data)
                completion(.success(decodedResponse.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func toggleSave(postId: String, isSaved: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = isSaved ? "unsavePost" : "savePost"
        guard let url = URL(string: "\(API_BASE_URL)/post/\(postId)/\(endpoint)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    func toggleFollow(userId: String, isFollowing: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = isFollowing ? "unfollow" : "follow"
        guard let url = URL(string: "\(API_BASE_URL)/user/\(userId)/\(endpoint)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}
