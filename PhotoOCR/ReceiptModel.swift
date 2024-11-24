import Foundation
import SwiftData

@Model
class ReceiptData {
    var businessName: String
    var address: String
    var phoneNumber: String
    var totalAmount: Double
    var gstAmount: Double?
    var transactionDate: Date
    var imageFilename: String
    var rawOCRText: String
    var dateCreated: Date
    
    init(
        businessName: String = "",
        address: String = "",
        phoneNumber: String = "",
        totalAmount: Double = 0.0,
        gstAmount: Double? = nil,
        transactionDate: Date = Date(),
        imageFilename: String = "",
        rawOCRText: String = "",
        dateCreated: Date = Date()
    ) {
        self.businessName = businessName
        self.address = address
        self.phoneNumber = phoneNumber
        self.totalAmount = totalAmount
        self.gstAmount = gstAmount
        self.transactionDate = transactionDate
        self.imageFilename = imageFilename
        self.rawOCRText = rawOCRText
        self.dateCreated = dateCreated
    }
} 