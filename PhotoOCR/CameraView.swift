import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            // Camera controls
            VStack {
                Spacer()
                Button(action: {
                    viewModel.capturePhoto()
                }) {
                    Circle()
                        .fill(viewModel.isSessionRunning ? .white : .gray)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(.black.opacity(0.8), lineWidth: 2)
                        )
                }
                .disabled(!viewModel.isSessionRunning)
                .padding(.bottom, 30)
            }
            
            // Loading indicator
            if !viewModel.isSessionRunning {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .alert("Camera Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            viewModel.checkCameraPermission()
        }
    }
}

// Camera preview representation
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
} 