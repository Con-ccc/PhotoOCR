import SwiftUI
import SwiftData
import PhotosUI

struct NewReceiptScanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var businessName = ""
    @State private var address = ""
    @State private var phoneNumber = ""
    @State private var transactionDate = Date()
    @State private var totalAmount = 0.0
    @State private var gstAmount: Double?
    @State private var rawText = ""
    
    private var isFormValid: Bool {
        !businessName.isEmpty && totalAmount > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                imageSection
                businessDetailsSection
                transactionDetailsSection
                if !rawText.isEmpty {
                    recognizedTextSection
                }
            }
            .navigationTitle("New Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReceipt()
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isProcessing {
                    loadingOverlay
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var imageSection: some View {
        Section("Receipt Image") {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(selectedImage == nil ? "Select Receipt" : "Change Receipt",
                      systemImage: "doc.viewfinder")
            }
            .onChange(of: selectedItem) { _ in
                processSelectedImage()
            }
        }
    }
    
    private var businessDetailsSection: some View {
        Section("Business Details") {
            TextField("Business Name", text: $businessName)
            TextField("Address", text: $address)
            TextField("Phone Number", text: $phoneNumber)
        }
    }
    
    private var transactionDetailsSection: some View {
        Section("Transaction Details") {
            DatePicker("Date", selection: $transactionDate)
            
            HStack {
                Text("$")
                TextField("Total Amount", value: $totalAmount, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            HStack {
                Text("GST $")
                TextField("GST Amount", value: $gstAmount, format: .number)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private var recognizedTextSection: some View {
        Section("Recognized Text") {
            Text(rawText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay {
                ProgressView("Processing Receipt...")
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(10)
            }
    }
    
    private func processSelectedImage() {
        Task {
            isProcessing = true
            
            do {
                if let selectedItem {
                    if let data = try await selectedItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        
                        // Perform OCR
                        let text = try await OCRService.recognizeText(from: image)
                        await processOCRText(text)
                        rawText = text
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isProcessing = false
        }
    }
    
    private func processOCRText(_ text: String) async {
        let lines = text.components(separatedBy: .newlines)
        
        if businessName.isEmpty {
            businessName = lines.first ?? ""
        }
        
        for line in lines {
            let lowercased = line.lowercased()
            
            if lowercased.contains("total") {
                if let total = extractAmount(from: line) {
                    totalAmount = total
                }
            }
            
            if lowercased.contains("gst") || lowercased.contains("tax") {
                if let gst = extractAmount(from: line) {
                    gstAmount = gst
                }
            }
            
            if lowercased.contains("phone") || lowercased.contains("tel") {
                phoneNumber = extractPhoneNumber(from: line) ?? phoneNumber
            }
            
            if let date = extractDate(from: line) {
                transactionDate = date
            }
        }
        
        let possibleAddress = lines.dropFirst().prefix(3).joined(separator: ", ")
        if address.isEmpty {
            address = possibleAddress
        }
    }
    
    private func extractAmount(from text: String) -> Double? {
        let pattern = #"\$?\s*(\d+\.?\d*)"#
        if let range = text.range(of: pattern, options: .regularExpression),
           let amount = Double(text[range].filter { "0123456789.".contains($0) }) {
            return amount
        }
        return nil
    }
    
    private func extractPhoneNumber(from text: String) -> String? {
        let pattern = #"(\d{3}[-.]?\d{3}[-.]?\d{4})"#
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    private func extractDate(from text: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        if let date = dateFormatter.date(from: text) {
            return date
        }
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.date(from: text)
    }
    
    private func saveReceipt() {
        let receipt = ReceiptData(
            businessName: businessName,
            address: address,
            phoneNumber: phoneNumber,
            totalAmount: totalAmount,
            gstAmount: gstAmount,
            transactionDate: transactionDate,
            imageFilename: "receipt_\(Date().timeIntervalSince1970)",
            rawOCRText: rawText,
            dateCreated: Date()
        )
        
        modelContext.insert(receipt)
        dismiss()
    }
} 