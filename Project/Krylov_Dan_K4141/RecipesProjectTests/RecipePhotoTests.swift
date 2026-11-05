import XCTest
import SwiftData
import UIKit
@testable import RecipesProject

class RecipePhotoTests: XCTestCase {
    @MainActor
    func testAPIReadsPhotoURLAndAllowsMissingPhoto() throws {
        let json = Data("""
        {"strMeal":"Soup","strCategory":"Starter","strInstructions":"Cook",
         "strMealThumb":"https://photos.example/photo.png","strIngredient1":"Water"}
        """.utf8)
        let meal = try JSONDecoder().decode(MealDetail.self, from: json)
        XCTAssertEqual(meal.photoURL, "https://photos.example/photo.png")
        XCTAssertEqual(RecipeAPI.convert(meal, type: nil).title, "Soup")

        let withoutPhoto = Data("{\"strMeal\":\"Soup\",\"strMealThumb\":null}".utf8)
        let otherMeal = try JSONDecoder().decode(MealDetail.self, from: withoutPhoto)
        XCTAssertTrue(otherMeal.photoURL.isEmpty)
    }

    @MainActor
    func testDownloadsImageFromURL() async throws {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        let data = try await RecipePhotoLoader.load(
            from: " https://photos.example/photo.png\n", session: session
        )
        XCTAssertEqual(data, PhotoURLProtocol.image)
        XCTAssertNotNil(UIImage(data: data))
    }

    @MainActor
    func testRejectsInvalidURL() async {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        for address in ["", "photo.png", "file:///tmp/photo.png"] {
            do {
                _ = try await RecipePhotoLoader.load(from: address, session: session)
                XCTFail("Неправильная ссылка не должна приниматься")
            } catch RecipePhotoLoader.PhotoError.invalidURL {
                // Ожидаем понятную ошибку ещё до сетевого запроса.
            } catch {
                XCTFail("Неожиданная ошибка: \(error)")
            }
        }
    }

    @MainActor
    func testRejectsHTTPError() async {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        do {
            _ = try await RecipePhotoLoader.load(from: "https://photos.example/missing", session: session)
            XCTFail("Ответ 404 не должен сохраняться как фото")
        } catch RecipePhotoLoader.PhotoError.badResponse {
        } catch {
            XCTFail("Неожиданная ошибка: \(error)")
        }
    }

    @MainActor
    func testRejectsWebPageInsteadOfImage() async {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        do {
            _ = try await RecipePhotoLoader.load(from: "https://photos.example/page", session: session)
            XCTFail("HTML-страница не должна сохраняться как фото")
        } catch RecipePhotoLoader.PhotoError.notAnImage {
        } catch {
            XCTFail("Неожиданная ошибка: \(error)")
        }
    }

    @MainActor
    func testRejectsOversizedDownload() async {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        do {
            _ = try await RecipePhotoLoader.load(from: "https://photos.example/large", session: session)
            XCTFail("Файл больше 10 МБ не должен сохраняться")
        } catch RecipePhotoLoader.PhotoError.tooLarge {
        } catch {
            XCTFail("Неожиданная ошибка: \(error)")
        }
    }

    @MainActor
    func testFailedReplacementKeepsExistingPhoto() async {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        let editor = RecipeEditorViewModel()
        editor.photo = PhotoURLProtocol.image
        editor.photoAddress = "https://photos.example/page"
        await editor.loadPhotoFromURL(session: session)
        XCTAssertEqual(editor.photo, PhotoURLProtocol.image)
        XCTAssertNotNil(editor.photoError)
        XCTAssertFalse(editor.isLoadingPhoto)
    }

    @MainActor
    func testDownloadedPhotoIsSavedInSwiftData() async throws {
        let session = makeSession()
        defer { session.invalidateAndCancel() }
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Recipe.self, configurations: config)
        let context = ModelContext(container)
        let editor = RecipeEditorViewModel()
        editor.title = "Суп с фотографией"
        editor.photoAddress = "https://photos.example/photo.png"
        await editor.loadPhotoFromURL(session: session)
        XCTAssertNil(editor.photoError)
        editor.save(context: context)
        try context.save()

        // Новому контексту не нужна сеть: фото уже находится в хранилище.
        let reopenedContext = ModelContext(container)
        let recipes = try reopenedContext.fetch(FetchDescriptor<Recipe>())
        let recipe = try XCTUnwrap(recipes.first)
        XCTAssertEqual(recipe.photo, PhotoURLProtocol.image)
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [PhotoURLProtocol.self]
        return URLSession(configuration: config)
    }
}

// Подменяем сеть фиксированными ответами: тесты работают без интернета.
private class PhotoURLProtocol: URLProtocol {
    static let image = Data(base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP438DwHwAGgAJ/EEwb4QAAAABJRU5ErkJggg=="
    ) ?? Data()

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.host == "photos.example"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else { return }
        let status = url.path == "/missing" ? 404 : 200
        guard let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil) else {
            return
        }
        var data = Self.image
        if url.path == "/page" {
            data = Data("<html>Это страница, а не фото</html>".utf8)
        } else if url.path == "/large" {
            data = Data(count: 10_000_001)
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}
