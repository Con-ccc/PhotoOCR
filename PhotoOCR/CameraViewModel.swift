import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isSessionRunning = false
    
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var photoData: Data?
    
    override init() {
        super.init()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            showError = true
            errorMessage = "Camera access is denied. Please enable it in Settings."
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        #if targetEnvironment(simulator)
        // Running in Simulator
        DispatchQueue.main.async {
            self.showError = true
            self.errorMessage = "Camera is not available in Simulator. Please test on a physical device."
        }
        return
        #else
        // Running on device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            DispatchQueue.main.async {
                self.showError = true
                self.errorMessage = "Could not find camera device"
            }
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.showError = true
                self.errorMessage = error.localizedDescription
            }
        }
        #endif
    }
    
    func capturePhoto() {
        guard isSessionRunning else {
            showError = true
            errorMessage = "Camera is not ready yet"
            return
        }
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    private func savePhoto(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        
        // Create TestPhotos directory if it doesn't exist
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let testPhotosPath = documentsPath.appendingPathComponent("TestPhotos")
        
        do {
            try fileManager.createDirectory(at: testPhotosPath, withIntermediateDirectories: true)
            
            // Generate unique filename with timestamp
            let timestamp = Date().timeIntervalSince1970
            let filename = "photo_\(Int(timestamp)).jpg"
            let fileURL = testPhotosPath.appendingPathComponent(filename)
            
            try imageData.write(to: fileURL)
            print("Photo saved successfully at: \(fileURL.path)")
        } catch {
            showError = true
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            showError = true
            errorMessage = error.localizedDescription
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            showError = true
            errorMessage = "Failed to process photo"
            return
        }
        
        savePhoto(imageData)
    }
} 