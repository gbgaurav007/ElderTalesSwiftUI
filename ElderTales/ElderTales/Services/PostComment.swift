//
//  PostComment.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation

struct PostComment: Identifiable, Decodable {
    var id: String {
        "\(user.id)-\(createdAt)"
    }
    let user: UserProfile
    let content: String
    let createdAt: String
    
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
