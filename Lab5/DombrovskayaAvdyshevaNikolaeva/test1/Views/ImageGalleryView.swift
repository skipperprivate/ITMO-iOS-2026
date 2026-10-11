import SwiftUI

struct ImageGalleryView: View {

    @StateObject private var viewModel: ImageGalleryViewModel

    init(urls: [URL]) {
        _viewModel = StateObject(wrappedValue: ImageGalleryViewModel(urls: urls))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear

            case .loading:
                ProgressView("Загрузка...")

            case .loaded(let images):
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(images.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: images[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }

            case .failed(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(message)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle("Картинки")
    }
}
