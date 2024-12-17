//
//  Profile.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import Foundation

struct UserProfiles: Decodable {
    let id: String
    let name: String
    let age: Int
    let contact: String
    let email: String
    let followerCount: Int?
    let followingCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case age
        case contact
        case email
        case followerCount
        case followingCount
    }
}

struct ProfileResponse: Decodable {
    let statusCode: Int
    let data: UserProfiles
    let message: String
    let success: Bool
}
struct FollowersFollowingResponse: Decodable {
    let statusCode: Int
    let data: FollowersFollowingData
    let message: String
    let success: Bool
}

struct FollowersFollowingData: Decodable {
    let followersCount: Int?
    let followingCount: Int?
    let followers: [UserProfiles]?
    let following: [UserProfiles]?
}
