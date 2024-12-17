//
//  Post.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation

struct APIResponse: Decodable {
    let statusCode: Int
    let data: [Post]
    let message: String
}

struct ToggleLikeResponse: Decodable {
    let statusCode: Int
    let data: LikeData
    let message: String
    let success: Bool
}

struct LikeData: Decodable {
    let likesCount: Int
    let isLiked: Bool
}

struct Post: Identifiable, Decodable {
    let id: String
    let description: String
    var media: [String]
    var likesCount: Int
    var commentsCount: Int
    let userName: String
    let userID: String
    let createdAt: String
    var isLiked: Bool
    var isSaved: Bool
    var isFollowing: Bool
    var comments: [PostComment]?
    var mediaURL: String {
        guard let url = media.first else { return "" }
        return url.hasPrefix("http://") ? url.replacingOccurrences(of: "http://", with: "https://") : url
    }
    
    // Custom coding keys to map JSON fields to Swift properties
    private enum CodingKeys: String, CodingKey {
        case id = "postId"
        case description
        case media
        case likesCount
        case commentsCount
        case user
        case createdAt
        case isLiked
        case comments
        case isSaved
        case isFollowing
        
        // Nested user keys
        enum UserKeys: String, CodingKey {
            case name
            case id
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        
        media = try container.decode([String].self, forKey: .media)
        
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        
        let userContainer = try container.nestedContainer(keyedBy: CodingKeys.UserKeys.self, forKey: .user)
        userName = try userContainer.decode(String.self, forKey: .name)
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount) ?? comments?.count ?? 0
        comments = try container.decodeIfPresent([PostComment].self, forKey: .comments)
        userID = try userContainer.decode(String.self, forKey: .id)
        isSaved = try container.decodeIfPresent(Bool.self, forKey: .isSaved) ?? false
        isFollowing = try container.decodeIfPresent(Bool.self, forKey: .isFollowing) ?? false
        
    }
    
    func formattedCreatedAt() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = formatter.date(from: createdAt) else {
            return "Invalid date"
        }
        
        let timeInterval = Date().timeIntervalSince(date)
        
        let minute: TimeInterval = 60
        let hour: TimeInterval = 60 * minute
        let day: TimeInterval = 24 * hour
        let month: TimeInterval = 30 * day
        
        if timeInterval < minute {
            return "\(Int(timeInterval)) seconds ago"
        } else if timeInterval < hour {
            return "\(Int(timeInterval / minute)) minutes ago"
        } else if timeInterval < day {
            return "\(Int(timeInterval / hour)) hours ago"
        } else if timeInterval < month {
            return "\(Int(timeInterval / day)) days ago"
        } else {
            return "\(Int(timeInterval / month)) months ago"
        }
    }
}

struct UserProfile: Decodable {
    let id: String
    let name: String
    let email: String
}
