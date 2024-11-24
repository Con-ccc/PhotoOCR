import Foundation

class SavedPhotosViewModel: ObservableObject {
    @Published var photos: [URL] = []
    
    func loadPhotos() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let testPhotosPath = documentsPath.appendingPathComponent("TestPhotos")
        
        do {
            // Create directory if it doesn't exist
            if !fileManager.fileExists(atPath: testPhotosPath.path) {
                try fileManager.createDirectory(at: testPhotosPath, withIntermediateDirectories: true)
            }
            
            // Get all files in the directory
            let photoURLs = try fileManager.contentsOfDirectory(
                at: testPhotosPath,
                includingPropertiesForKeys: nil
            )
            
            // Filter for image files and sort by creation date (newest first)
            photos = photoURLs
                .filter { $0.pathExtension.lowercased() == "jpg" }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    return date1 > date2
                }
        } catch {
            print("Error loading photos: \(error)")
        }
    }
} 