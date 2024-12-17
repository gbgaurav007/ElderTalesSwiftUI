//
//  APIManeger.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import Foundation

class APIManager {
    
    func uploadPost(description: String, mediaURLs: [URL], completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(API_BASE_URL)/post/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(getAccessToken())", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(description)\r\n".data(using: .utf8)!)
        
        for url in mediaURLs {
            do {
                let fileData = try Data(contentsOf: url)
                let fileName = url.lastPathComponent
                let mimeType = getMimeType(for: url)
                
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n".data(using: .utf8)!)
            } catch {
                print("Error reading file: \(error)")
                completion(false, "Failed to read file: \(url.lastPathComponent)")
                return
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading post: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, "Network error occurred.")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "No response data received.")
                }
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let message = jsonResponse?["message"] as? String {
                    print("Server Response: \(message)")
                    DispatchQueue.main.async {
                        completion(true, message)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "Failed to parse server response.")
                    }
                }
            } catch {
                print("Error decoding server response: \(error)")
                DispatchQueue.main.async {
                    completion(false, "Error parsing response data.")
                }
            }
        }.resume()
    }
    
    private func getMimeType(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        switch fileExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "mp4":
            return "video/mp4"
        default:
            return "application/octet-stream"
        }
    }
}
