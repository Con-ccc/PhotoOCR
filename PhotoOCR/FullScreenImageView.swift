import SwiftUI
import SwiftData

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let image: UIImage
    
    @State private var recognizedText: String = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showOCROptions = false
    @State private var minimumTextHeight: Float = 0.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    if isProcessing {
                        VStack {
                            ProgressView("Processing text...")
                            Text("This may take a few seconds")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if !recognizedText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Recognized Text:")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button {
                                    UIPasteboard.general.string = recognizedText
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            
                            Text(recognizedText)
                                .textSelection(.enabled)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Scan Whole Image") {
                            minimumTextHeight = 0.0
                            performOCR()
                        }
                        
                        Button("Scan Large Text Only") {
                            minimumTextHeight = 0.1
                            performOCR()
                        }
                        
                        if !recognizedText.isEmpty {
                            Button("Copy to Clipboard") {
                                UIPasteboard.general.string = recognizedText
                            }
                        }
                    } label: {
                        Image(systemName: "text.viewfinder")
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func performOCR() {
        isProcessing = true
        
        Task {
            do {
                let text = try await OCRService.recognizeText(from: image, minimumTextHeight: minimumTextHeight)
                
                // Save to SwiftData
                let filename = "image_\(Date().timeIntervalSince1970)"
                let result = TextRecognitionResult(text: text, imageFilename: filename)
                modelContext.insert(result)
                
                await MainActor.run {
                    self.recognizedText = text
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isProcessing = false
                }
            }
        }
    }
} 