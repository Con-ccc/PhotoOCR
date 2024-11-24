import SwiftUI

struct SavedPhotosView: View {
    @StateObject private var viewModel = SavedPhotosViewModel()
    @State private var selectedPhoto: PhotoItem?
    @State private var showPhotoDetail = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.photos.isEmpty {
                    ContentUnavailableView(
                        "No Photos",
                        systemImage: "photo.stack",
                        description: Text("Photos you capture will appear here")
                    )
                    .symbolRenderingMode(.multicolor)
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(viewModel.photos, id: \.self) { photoURL in
                            PhotoGridItem(photoURL: photoURL) { image in
                                selectedPhoto = PhotoItem(image: image, url: photoURL)
                                showPhotoDetail = true
                            }
                        }
                    }
                    .padding(1)
                }
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.loadPhotos()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                viewModel.loadPhotos()
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
        }
    }
}

struct PhotoGridItem: View {
    let photoURL: URL
    let onTap: (UIImage) -> Void
    
    @State private var image: UIImage?
    @State private var thumbnailSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTap(image)
                        }
                } else {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .background(Color(.systemGray6))
                }
            }
            .onAppear {
                thumbnailSize = geometry.size
                loadImage()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(8)
    }
    
    private func loadImage() {
        Task {
            do {
                let imageData = try Data(contentsOf: photoURL)
                if let loadedImage = UIImage(data: imageData) {
                    // Create thumbnail for better performance
                    let thumbnail = await createThumbnail(from: loadedImage)
                    await MainActor.run {
                        self.image = thumbnail
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    private func createThumbnail(from image: UIImage) async -> UIImage {
        let size = thumbnailSize.width * UIScreen.main.scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        let thumbnail = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        }
        return thumbnail
    }
}

struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let photo: PhotoItem
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale = scale * delta
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation {
                                scale = scale > 1 ? 1 : 2
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .opacity(scale != 1.0 || offset != .zero ? 1 : 0)
                }
            }
            .background(Color.black)
        }
    }
}

struct PhotoItem: Identifiable {
    let id = UUID()
    let image: UIImage
    let url: URL
} 