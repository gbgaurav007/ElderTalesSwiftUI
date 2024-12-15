//
//  PostDetails.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation

struct LikeResponse: Decodable {
    let isLiked: Bool
    let likesCount: Int
}

struct PostDetailsResponse: Decodable {
    let data: Post
}

struct AddCommentResponse: Decodable {
    let statusCode: Int
    let data: CommentData
    let message: String
    let success: Bool
    
    struct CommentData: Decodable {
        let user: String
        let name: String
        let content: String
        let createdAt: String
    }
}
