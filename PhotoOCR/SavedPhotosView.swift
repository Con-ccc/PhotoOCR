import SwiftUI

struct SavedPhotosView: View {
    @StateObject private var viewModel = SavedPhotosViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.photos.isEmpty {
                    ContentUnavailableView(
                        "No Photos",
                        systemImage: "photo.stack",
                        description: Text("Photos you capture will appear here")
                    )
                    .symbolRenderingMode(.multicolor)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(viewModel.photos, id: \.self) { photoURL in
                                PhotoThumbnail(photoURL: photoURL)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.loadPhotos()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadPhotos()
        }
    }
}

struct PhotoThumbnail: View {
    let photoURL: URL
    @State private var image: UIImage?
    @State private var showFullScreen = false
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .onTapGesture {
                        showFullScreen = true
                    }
            } else {
                ProgressView()
                    .frame(minHeight: 100)
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let image {
                FullScreenImageView(image: image)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        do {
            let imageData = try Data(contentsOf: photoURL)
            if let loadedImage = UIImage(data: imageData) {
                await MainActor.run {
                    self.image = loadedImage
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
} 