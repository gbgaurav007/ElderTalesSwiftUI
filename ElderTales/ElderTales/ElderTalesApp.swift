//
//  ElderTalesApp.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 04/12/24.
//

import SwiftUI

@main
struct ElderTalesApp: App {
    @State private var isLoggedIn = false
    @State private var userData: UserData?
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView(isLoggedIn: $isLoggedIn, userData: $userData)
            } else {
                AccountView(isLoggedIn: $isLoggedIn, updateUserData: { userData in
                    self.userData = userData
                })
            }
        }
    }
}
