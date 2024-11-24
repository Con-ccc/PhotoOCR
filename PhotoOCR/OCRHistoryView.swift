import SwiftUI
import SwiftData

struct OCRHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TextRecognitionResult.dateCreated, order: .reverse) private var results: [TextRecognitionResult]
    
    var body: some View {
        NavigationStack {
            Group {
                if results.isEmpty {
                    ContentUnavailableView(
                        "No OCR Results",
                        systemImage: "text.viewfinder",
                        description: Text("Scan some text from your photos")
                    )
                } else {
                    List {
                        ForEach(results) { result in
                            NavigationLink(destination: OCRDetailView(result: result)) {
                                OCRHistoryRow(result: result)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(result)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("OCR History")
        }
    }
}

struct OCRHistoryRow: View {
    let result: TextRecognitionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.text.prefix(100))
                .lineLimit(2)
                .font(.body)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(result.dateCreated, style: .date)
                
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text(result.dateCreated, style: .time)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct OCRDetailView: View {
    let result: TextRecognitionResult
    @Environment(\.dismiss) private var dismiss
    @State private var isSharePresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date and Time
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text(result.dateCreated, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        
                        Label {
                            Text(result.dateCreated, style: .time)
                        } icon: {
                            Image(systemName: "clock")
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                
                // Recognized Text
                GroupBox("Recognized Text") {
                    Text(result.text)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                
                // File Information
                GroupBox("File Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text(result.imageFilename)
                                .textSelection(.enabled)
                        } icon: {
                            Image(systemName: "doc")
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("OCR Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        UIPasteboard.general.string = result.text
                    } label: {
                        Label("Copy Text", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        isSharePresented = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isSharePresented) {
            ShareSheet(items: [result.text])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        OCRDetailView(result: TextRecognitionResult(
            text: "Sample OCR text that was recognized from an image. This could be multiple lines long and contain various types of content.",
            imageFilename: "sample_image_123.jpg"
        ))
    }
} 