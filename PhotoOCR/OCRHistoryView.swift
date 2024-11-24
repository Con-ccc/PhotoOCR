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
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result.text)
                                    .lineLimit(2)
                                Text(result.dateCreated, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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