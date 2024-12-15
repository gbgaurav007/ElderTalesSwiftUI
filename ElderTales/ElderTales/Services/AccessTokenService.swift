//
//  AccessTokenService.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 15/12/24.
//

import Foundation


func getAccessToken() -> String {
    if let cookies = HTTPCookieStorage.shared.cookies {
        for cookie in cookies {
            if cookie.name == "accessToken" {
                print("Access Token: \(cookie.value)")
                return cookie.value
            }
        }
    }
    return ""
}
