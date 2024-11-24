import Vision
import UIKit

class OCRService {
    static func recognizeText(from image: UIImage, minimumTextHeight: Float = 0.0) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "OCRService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage"])
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest()
        
        // Configure for maximum coverage and accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = minimumTextHeight // 0.0 means any text size
        request.recognitionLanguages = ["en-US"] // Add more languages as needed
        
        // Process the whole image
        request.regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        try await requestHandler.perform([request])
        
        guard let observations = request.results else {
            throw NSError(domain: "OCRService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No text found"])
        }
        
        // Sort observations by vertical position (top to bottom)
        let sortedObservations = observations.sorted { first, second in
            let firstY = first.boundingBox.origin.y
            let secondY = second.boundingBox.origin.y
            return firstY > secondY
        }
        
        // Get all candidates and join them
        let recognizedStrings = sortedObservations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }
        
        return recognizedStrings.joined(separator: "\n")
    }
} 