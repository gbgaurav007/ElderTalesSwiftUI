//
//  CameraView.swift
//  ElderTales
//
//  Created by Gaurav Bansal on 17/12/24.
//

import SwiftUI
import AVKit
import PhotosUI
import AVFoundation
import UIKit

class VideoRecorder: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var videoURL: URL?

    var captureSession: AVCaptureSession!
    private var movieOutput: AVCaptureMovieFileOutput!
    private var videoCompletion: ((URL?) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("No camera/audio available")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if captureSession.canAddInput(videoInput) { captureSession.addInput(videoInput) }
            if captureSession.canAddInput(audioInput) { captureSession.addInput(audioInput) }
            
            movieOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
            }
            
            captureSession.startRunning()
        } catch {
            print("Error setting up capture session: \(error)")
        }
    }
    func startRecording() {
        let outputDirectory = FileManager.default.temporaryDirectory
        let outputURL = outputDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        print("Recording started: \(outputURL)")
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            videoCompletion = completion
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            videoCompletion?(nil)
        } else {
            print("Recording finished: \(outputFileURL)")
            videoCompletion?(outputFileURL)
        }
    }
}

struct VideoPlayerView: View {
    let url: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
            .onAppear {
                AVPlayer(url: url).play()
            }
            .cornerRadius(10)
    }
}

struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var videoURL: URL?
    @Binding var isPresented: Bool
    @StateObject private var videoRecorder = VideoRecorder()
    @State private var isRecording = false
    
    var body: some View {
        ZStack {
            CameraPreview(session: videoRecorder.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: toggleRecording) {
                    Circle()
                        .fill(isRecording ? Color.red : Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                }
                .padding()
            }
        }
        .onAppear {
            videoRecorder.captureSession.startRunning()
        }
        .onDisappear {
            videoRecorder.captureSession.stopRunning()
        }
    }
    private func toggleRecording() {
        if isRecording {
            videoRecorder.stopRecording { url in
                if let url = url {
                    videoURL = url
                    isPresented = false
                    print("Video saved at: \(url)")
                    print("VideoURL: \(videoURL!)")
                    presentationMode.wrappedValue.dismiss()
                }
                isRecording = false
            }
        } else {
            videoRecorder.startRecording()
            isRecording = true
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}
