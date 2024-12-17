//
//  PeopleProfile.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import Foundation

struct PeopleUserProfiles: Decodable {
    let id: String
    let name: String
    let age: Int
    let contact: String
    let email: String
    let posts: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case age
        case contact
        case email
        case posts
    }
}

struct PeopleProfileResponse: Decodable {
    let statusCode: Int
    let data: ProfileData
    let message: String
    let success: Bool
}

struct ProfileData: Decodable {
    let user: PeopleUserProfiles
    let followersCount: Int
    let followingCount: Int
}
