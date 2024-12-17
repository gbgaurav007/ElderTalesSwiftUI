//
//  PeopleProfileViewModel.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import Foundation

class PeopleProfileViewModel: ObservableObject {
    @Published var userProfile: PeopleUserProfiles?
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var posts: [Post] = []
    
    func fetchPeopleProfile(userId: String) {
        guard let url = URL(string: "\(API_BASE_URL)/auth/user/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Network Error PeopleProfile: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    print("No data received from server PeopleProfile")
                    self.errorMessage = "No data received"
                    return
                }
                
                if let rawJSONString = String(data: data, encoding: .utf8) {
                    print("Raw JSON PeopleProfile Response:\n\(rawJSONString)")
                } else {
                    print("Failed to convert data to string PeopleProfile")
                }
                do {
                    let response = try JSONDecoder().decode(PeopleProfileResponse.self, from: data)
                    print("Successfully decoded response PeopleProfile")
                    self.userProfile = response.data.user
                    self.followersCount = response.data.followersCount
                    self.followingCount = response.data.followingCount
                } catch {
                    print("Decoding Error: \(error)")
                    self.errorMessage = "Failed to decode PeopleProfile response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchUsersPosts(userId: String) {
        guard let url = URL(string: "\(API_BASE_URL)/post/\(userId)/posts") else { return }
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
}
