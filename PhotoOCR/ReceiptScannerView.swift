import SwiftUI
import SwiftData

struct ReceiptScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReceiptData.dateCreated, order: .reverse) private var receipts: [ReceiptData]
    
    var body: some View {
        NavigationStack {
            Group {
                if receipts.isEmpty {
                    ContentUnavailableView(
                        "No Receipts",
                        systemImage: "receipt",
                        description: Text("Scan receipts to track your expenses")
                    )
                } else {
                    List {
                        ForEach(receipts) { receipt in
                            NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                                ReceiptRowView(receipt: receipt)
                            }
                        }
                        .onDelete(perform: deleteReceipts)
                    }
                }
            }
            .navigationTitle("Receipts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NewReceiptScanView()) {
                        Image(systemName: "doc.text.viewfinder")
                    }
                }
            }
        }
    }
    
    private func deleteReceipts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(receipts[index])
        }
    }
}

struct ReceiptRowView: View {
    let receipt: ReceiptData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(receipt.businessName)
                .font(.headline)
            Text(receipt.transactionDate, style: .date)
                .font(.subheadline)
            Text(String(format: "Total: $%.2f", receipt.totalAmount))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
} 