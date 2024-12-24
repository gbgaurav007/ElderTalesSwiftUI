//
//  ContentView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 04/12/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var isLoggedIn : Bool
    @Binding var userData: UserData?
    
    
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            // Your Rides Tab
            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Add Post")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}
