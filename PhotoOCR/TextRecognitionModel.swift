import Foundation
import SwiftData

@Model
class TextRecognitionResult {
    var text: String
    var imageFilename: String
    var dateCreated: Date
    
    init(text: String, imageFilename: String, dateCreated: Date = Date()) {
        self.text = text
        self.imageFilename = imageFilename
        self.dateCreated = dateCreated
    }
} 