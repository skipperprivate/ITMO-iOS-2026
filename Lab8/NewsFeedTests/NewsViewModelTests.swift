import XCTest
@testable import iOS_final_project

final class NewsViewModelTests: XCTestCase {
    private enum TestError: Error {
        case readFailed
    }

    @MainActor
    private func makeViewModel(
        storage: MockNewsStorage
    ) throws -> NewsViewModel {
        let suiteName = "NewsViewModelTests.\(UUID().uuidString)"

        let defaults = try XCTUnwrap(
            UserDefaults(suiteName: suiteName)
        )

        addTeardownBlock {
            UserDefaults(suiteName: suiteName)?
                .removePersistentDomain(forName: suiteName)
        }

        return NewsViewModel(
            storage: storage,
            defaults: defaults
        )
    }

    @MainActor
    func testUnknownNewsDoesNotChangeFavorites() throws {
        let storage = MockNewsStorage(news: [
            News(id: 1, title: "Новость", text: "Текст")
        ])

        let viewModel = try makeViewModel(storage: storage)

        let unknownNews = News(
            id: 999,
            title: "Неизвестная новость",
            text: "Текст"
        )

        viewModel.toggleFavorite(unknownNews)

        XCTAssertEqual(viewModel.news.count, 1)
        XCTAssertEqual(viewModel.news.first?.id, 1)
        XCTAssertEqual(viewModel.news.first?.isFavorite, false)
        XCTAssertEqual(storage.saveCount, 0)
    }

    @MainActor
    func testStorageReadErrorIsHandled() throws {
        let storage = MockNewsStorage()
        storage.readError = TestError.readFailed

        let viewModel = try makeViewModel(storage: storage)

        XCTAssertTrue(viewModel.news.isEmpty)
        XCTAssertEqual(
            viewModel.errorMessage,
            "Не удалось прочитать сохранённые новости."
        )
    }
}
