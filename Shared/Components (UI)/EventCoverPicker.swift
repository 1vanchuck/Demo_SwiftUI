import SwiftUI
import PhotosUI

struct EventCoverPicker: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable().aspectRatio(contentMode: .fill).frame(height: 200)
                } else {
                    Rectangle().fill(Color.secondary.opacity(0.1)).frame(height: 200)
                        .overlay(Image(systemName: "photo.on.rectangle.angled").font(.largeTitle).foregroundColor(.secondary))
                }
                Image(systemName: "pencil.circle.fill").font(.title).foregroundColor(.white)
                    .background(Color.black.opacity(0.5).clipShape(Circle()))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing).padding(8)
            }
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImage = UIImage(data: data)
                }
            }
        }
    }
}

#Preview {
    // Для превью нам нужно создать "фейковые" состояния
    struct PreviewWrapper: View {
        @State private var item: PhotosPickerItem?
        @State private var image: UIImage?
        
        var body: some View {
            EventCoverPicker(selectedPhotoItem: $item, selectedImage: $image)
                .padding()
        }
    }
    
    return PreviewWrapper()
}
