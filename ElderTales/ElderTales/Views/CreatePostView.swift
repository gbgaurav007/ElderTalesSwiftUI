//
//  CreatePostView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import SwiftUI
import AVKit
import PhotosUI
import AVFoundation
import UIKit

struct CreatePostView: View {
    @State private var description: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedURLs: [URL] = []
    @State private var videoURL: URL? = nil
    @State private var isPresentingCamera = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var keyboardFocused: Bool
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .leading) {
                    Text("New Post")
                        .font(.largeTitle).bold()
                        .padding()
                    
                    Spacer()
                    
                    Text("✨ Inspiration")
                        .font(.title2)
                        .padding()
                    
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .any(of: [.images, .videos])) {
                        Label("Choose media files", systemImage: "photo.on.rectangle")
                    }
                    .padding()
                    .onChange(of: selectedItems) {
                        Task {
                            selectedURLs.removeAll()
                            for item in selectedItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    let tempURL = saveTemporaryFile(data: data, fileExtension: item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg")
                                    selectedURLs.append(tempURL)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        isPresentingCamera = true
                    }) {
                        Text("Record a Video")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding()
                    .sheet(isPresented: $isPresentingCamera, onDismiss: {
                        if let url = videoURL {
                            selectedURLs.append(url)
                            print("Video URL appended to selectedURLs: \(url)")
                        }
                    }) {
                        CameraView(videoURL: $videoURL, isPresented: $isPresentingCamera)
                    }
                    
                    TextField("Add description...", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    if let videoURL = videoURL {
                        VideoPlayerView(url: videoURL)
                            .frame(height: 300)
                    }
                    
                    Spacer()
                    Button(action: createPost) {
                        Text("Post")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.indigo)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .onAppear(perform: checkPhotoPermissions)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Post Status"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            if alertMessage == "Post created successfully!" {
                                resetFields()
                            }
                        }
                    )
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button("Done") {
                            keyboardFocused = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
        }
    }
    
    func saveTemporaryFile(data: Data, fileExtension: String) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving temporary file: \(error)")
        }
        return fileURL
    }

    func createPost() {
        let apiManager = APIManager()
        apiManager.uploadPost(description: description, mediaURLs: selectedURLs) { success, message in
            if success {
                print("Post created successfully!")
            } else {
                print("Failed to create post: \(message ?? "Unknown error")")
            }
        }
    }
    
    func checkPhotoPermissions() {
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                print("Photo library access denied.")
            }
        }
    }
    
    func resetFields() {
            description = ""
            videoURL = nil
            selectedItems = []
            selectedURLs = []
        }
}






