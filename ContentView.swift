import SwiftUI
import VisionKit
import Vision

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var recognizedText = ""
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            Text(recognizedText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button("Select Photo") {
                showImagePicker = true
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, completionHandler: performOCR)
        }
    }
    
    private func performOCR(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.recognizedText = text
            }
        }
        
        // Configure the recognition level
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing OCR: \(error)")
        }
    }
} 