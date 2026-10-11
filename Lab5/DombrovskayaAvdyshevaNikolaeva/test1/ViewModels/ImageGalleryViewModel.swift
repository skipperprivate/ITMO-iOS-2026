import Foundation
import Combine

@MainActor
final class ImageGalleryViewModel: ObservableObject {

    enum State {
        case idle
        case loading
        case loaded([Data])
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let urls: [URL]

    init(urls: [URL]) {
        self.urls = urls
    }

    func load() async {
        state = .loading

        let images = await ImageLoader.loadImages(from: urls)

        if images.isEmpty {
            state = .failed("Не удалось загрузить ни одну картинку")
        } else {
            state = .loaded(images)
        }
    }
}
