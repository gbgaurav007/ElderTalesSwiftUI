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
    
    
}
