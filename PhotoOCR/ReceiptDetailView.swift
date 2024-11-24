import SwiftUI
import SwiftData

struct ReceiptDetailView: View {
    let receipt: ReceiptData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Business Information
                GroupBox("Business Information") {
                    VStack(alignment: .leading, spacing: 10) {
                        DetailRow(title: "Name", value: receipt.businessName)
                        DetailRow(title: "Address", value: receipt.address)
                        DetailRow(title: "Phone", value: receipt.phoneNumber)
                    }
                }
                
                // Transaction Details
                GroupBox("Transaction Details") {
                    VStack(alignment: .leading, spacing: 10) {
                        DetailRow(title: "Date", value: receipt.transactionDate.formatted(date: .long, time: .shortened))
                        DetailRow(title: "Total", value: String(format: "$%.2f", receipt.totalAmount))
                        if let gst = receipt.gstAmount {
                            DetailRow(title: "GST", value: String(format: "$%.2f", gst))
                        }
                    }
                }
                
                // Raw OCR Text
                if !receipt.rawOCRText.isEmpty {
                    GroupBox("Original Text") {
                        Text(receipt.rawOCRText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        ReceiptDetailView(receipt: ReceiptData(
            businessName: "Sample Store",
            address: "123 Main St",
            phoneNumber: "555-1234",
            totalAmount: 99.99,
            gstAmount: 10.00,
            transactionDate: Date(),
            rawOCRText: "Sample receipt text..."
        ))
    }
} 