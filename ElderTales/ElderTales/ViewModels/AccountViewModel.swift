//
//  AccountViewModel.swift
//
//  Created by Gaurav Bansal on 27/10/24.
//


import SwiftUI
import Combine

func saveAccessTokenToCookies(token: String) {
    let cookieProperties: [HTTPCookiePropertyKey: Any] = [
        .name: "accessToken",
        .value: token,
        .domain: "localhost", // Adjust domain to match your server setup
        .path: "/",
        .expires: Date().addingTimeInterval(60 * 60 * 24)
    ]
    
    if let cookie = HTTPCookie(properties: cookieProperties) {
        HTTPCookieStorage.shared.setCookie(cookie)
        print("AccessToken saved to cookies: \(cookie)")
    } else {
        print("Failed to create cookie.")
    }
}


class AccountViewModel: ObservableObject {
    @Published var isLogin: Bool = true
    @Published var formData: FormData = FormData()
    @Published var errors: FormErrors = FormErrors()
    @Published var alertMessage: String?
    @Published var isAlertPresented: Bool = false
    @Published var showPassword: Bool = false
    @Binding var isLoggedIn: Bool
    @Published var userData: UserData?
    @Published var isLoading = false
    
    
    var updateUserData: ((UserData) -> Void)?
    
    struct FormData {
        var name: String = ""
        var contact: String = ""
        var age: Int = 50
        var email: String = ""
        var password: String = ""
    }
    
    struct FormErrors {
        var email: String = ""
        var contact: String = ""
        var password: String = ""
    }
    
    init(isLoggedIn: Binding<Bool>, updateUserData: ((UserData) -> Void)? = nil) {
        _isLoggedIn = isLoggedIn
        self.updateUserData = updateUserData
    }
    
    func handleLogin() {
        isLoading = true
        
        let url = URL(string: "\(API_BASE_URL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": formData.email, "password": formData.password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Request URL: \(url)")
        print("Request Body: \(body)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Login failed: \(error.localizedDescription)"
                    self.isAlertPresented = true
                    
                }
                print("Error: \(error.localizedDescription)")
                return
            }
            // Debug: Print raw received data
            if let data = data {
                print("Raw Data Received: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
            }
            
            
            guard let data = data else { return }
            do {
                let jsonResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                print("Parsed Response: \(jsonResponse)")
                if jsonResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                        self.userData = jsonResponse.data
                        self.updateUserData?(jsonResponse.data)
                    }
                    saveAccessTokenToCookies(token: jsonResponse.data.accessToken)
                }
                else {
                    DispatchQueue.main.async {
                        self.alertMessage = jsonResponse.message
                        self.isAlertPresented = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to decode response"
                    self.isAlertPresented = true
                }
                print("Decoding Error: \(error)")
            }
        }.resume()
    }
    
    func handleSignup() {
        isLoading = true
        
        let url = URL(string: "\(API_BASE_URL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["name": formData.name, "contact": formData.contact, "age": formData.age, "email": formData.email, "password": formData.password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Request URL: \(url)")
        print("Request Body: \(body)")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Registration failed: \(error.localizedDescription)"
                    self.isAlertPresented = true
                }
                print("Error: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                print("HTTP Response Headers: \(httpResponse.allHeaderFields)")
            }
            if let data = data {
                print("Raw Data Received: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
            }
            
            guard let data = data else { return }
            do {
                let jsonResponse = try JSONDecoder().decode(SignupResponse.self, from: data)
                
                print("Parsed Response: \(jsonResponse)")
                if jsonResponse.statusCode == 201 {
                    DispatchQueue.main.async {
                        self.alertMessage = "Signup Successful"
                        self.isAlertPresented = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = jsonResponse.message
                        self.isAlertPresented = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to decode response"
                    self.isAlertPresented = true
                }
                print("Decoding Error: \(error)")
            }
        }.resume()
    }
}
