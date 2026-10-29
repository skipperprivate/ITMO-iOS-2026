import XCTest
@testable import iOS_final_project

final class MyPostsViewModelTests: XCTestCase {
    @MainActor
    func testCreatedPostsAreSavedWithUniqueIdentifiers() throws {
        let filename = "MyPostsTests-\(UUID().uuidString).json"
        let fileURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(filename)

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let storage = FileNewsStorage(filename: filename)
        let viewModel = MyPostsViewModel(storage: storage)

        try viewModel.add(APIPost(id: 101, title: "Первый пост", body: "Первый текст"))
        try viewModel.add(APIPost(id: 101, title: "Второй пост", body: "Второй текст"))

        let reloadedViewModel = MyPostsViewModel(storage: storage)

        XCTAssertEqual(reloadedViewModel.posts.map(\.title), ["Второй пост", "Первый пост"])
        XCTAssertEqual(reloadedViewModel.posts.map(\.text), ["Второй текст", "Первый текст"])
        XCTAssertEqual(Set(reloadedViewModel.posts.map(\.id)).count, 2)
        XCTAssertNil(reloadedViewModel.errorMessage)
    }
}