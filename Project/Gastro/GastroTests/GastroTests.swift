import XCTest

@testable import Untitled_Project

@MainActor
final class GastroTests: XCTestCase {
    func testInvalidRecipeDoesNotSaveOrPublish() async {
        for missingField in 0..<3 {
            let interactor = EditorInteractorSpy()
            let router = EditorRouterSpy()
            let presenter = makePresenter(interactor, router: router)

            switch missingField {
                case 0: presenter.setTitle("  ")
                case 1: presenter.setIngredient(at: 0, to: "  ")
                default: presenter.setStep(at: 0, to: "  ")
            }

            presenter.save()

            XCTAssertNotNil(presenter.state.error)

            await presenter.publish()

            XCTAssertNotNil(presenter.state.toast)
            XCTAssertFalse(presenter.state.isPublishing)
            XCTAssertEqual(interactor.savedDrafts.count, 0)
            XCTAssertEqual(interactor.publishedDrafts.count, 0)
            XCTAssertEqual(router.backCount, 0)
        }
    }

    func testPublicationSendsCorrectPOSTAndJSON() async throws {
        let client = makeClient()
        let draft = RecipeDraft(
            title: "Омлет",
            ingredients: ["Яйца", "Молоко"],
            steps: ["Смешать"],
            cookingTimeMinutes: 10
        )

        let response = try await client.send(request: RecipeRequests.publish(draft: draft))
        // The URLProtocol echoes what URLSession actually received, including its body stream.
        let echo = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(response.name.utf8)) as? [String: Any])
        XCTAssertEqual(echo["method"] as? String, "POST")
        XCTAssertEqual(echo["url"] as? String, "https://unit-tests.invalid/recipes/add")
        XCTAssertEqual(echo["accept"] as? String, "application/json")
        XCTAssertEqual(echo["contentType"] as? String, "application/json")

        let body = try XCTUnwrap(echo["body"] as? [String: Any])
        XCTAssertEqual(Set(body.keys), ["name", "ingredients", "instructions", "cookTimeMinutes"])
        XCTAssertEqual(body["name"] as? String, draft.title)
        XCTAssertEqual(body["ingredients"] as? [String], draft.ingredients)
        XCTAssertEqual(body["instructions"] as? [String], draft.steps)
        XCTAssertEqual(body["cookTimeMinutes"] as? Int, 10)
    }

    func testHTTPFailuresPreserveStatusCode() async {
        let client = makeClient()
        for status in [400, 401, 429, 500] {
            do {
                let request = NetworkRequest<PublishRecipeResponse>(
                    path: "http/\(status)",
                    method: .post,
                    body: Data("{}".utf8)
                )
                _ = try await client.send(request: request)
                XCTFail("Expected HTTP \(status) to throw")
            } catch NetworkError.httpStatus(let actual) {
                XCTAssertEqual(actual, status)
            } catch {
                XCTFail("Expected httpStatus, got \(error)")
            }
        }
    }

    func testSuccessfulPublicationClearsLoadingWithoutError() async {
        let interactor = EditorInteractorSpy()
        let entered = expectation(description: "Publication started")
        interactor.onPublish = { entered.fulfill() }
        let presenter = makePresenter(interactor)
        let task = Task { await presenter.publish() }
        await fulfillment(of: [entered], timeout: 2)
        XCTAssertTrue(presenter.state.isPublishing)
        XCTAssertNil(presenter.state.toast)
        XCTAssertEqual(interactor.publishedDrafts.count, 1)
        interactor.finish(.success(PublishedRecipe(id: 51, name: "Омлет")))
        await task.value
        XCTAssertFalse(presenter.state.isPublishing)
        XCTAssertNil(presenter.state.toast)
        XCTAssertNil(presenter.state.error)
    }

    func testFailedPublicationShowsToastAndClearsLoading() async {
        let interactor = EditorInteractorSpy()
        let entered = expectation(description: "Publication started")
        interactor.onPublish = { entered.fulfill() }
        let presenter = makePresenter(interactor)
        let task = Task { await presenter.publish() }
        await fulfillment(of: [entered], timeout: 2)
        XCTAssertTrue(presenter.state.isPublishing)
        interactor.finish(.failure(NetworkError.httpStatus(500)))
        await task.value
        XCTAssertFalse(presenter.state.isPublishing)
        XCTAssertEqual(presenter.state.toast?.text, "Ошибка сервера (HTTP 500). Попробуйте позже.")
    }

    private func makePresenter(
        _ interactor: EditorInteractorSpy,
        router: EditorRouterSpy? = nil
    )
        -> RecipeEditorPresenter
    {
        let presenter = RecipeEditorPresenter(id: nil, interactor: interactor, router: router ?? EditorRouterSpy())
        presenter.setTitle("Омлет")
        presenter.setIngredient(at: 0, to: "Яйца")
        presenter.setStep(at: 0, to: "Смешать")
        return presenter
    }

    private func makeClient() -> NetworkClientImpl {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [RecordingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        addTeardownBlock { session.invalidateAndCancel() }
        return NetworkClientImpl(baseURL: URL(string: "https://unit-tests.invalid")!, session: session)
    }
}

@MainActor
private final class EditorInteractorSpy: RecipeEditorInteractor {
    var savedDrafts: [RecipeDraft] = []
    var publishedDrafts: [RecipeDraft] = []
    var onPublish: (() -> Void)?
    private var continuation: CheckedContinuation<PublishedRecipe, Error>?

    func recipe(id: UUID) throws -> Recipe? {
        nil
    }

    func create(_ draft: RecipeDraft) throws {
        savedDrafts.append(draft)
    }

    func update(id: UUID, with draft: RecipeDraft) throws {
        savedDrafts.append(draft)
    }

    func publish(_ draft: RecipeDraft) async throws -> PublishedRecipe {
        publishedDrafts.append(draft)
        return try await withCheckedThrowingContinuation {
            continuation = $0
            onPublish?()
        }
    }

    func finish(_ result: Result<PublishedRecipe, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

@MainActor
private final class EditorRouterSpy: RecipeEditorRouter {
    var backCount = 0

    func goBack() {
        backCount += 1
    }
}

private final class RecordingURLProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            let url = try XCTUnwrap(request.url)
            let status = Int(url.lastPathComponent) ?? 201
            let data: Data
            if status >= 400 {
                // Deliberately invalid JSON: status must be checked before decoding.
                data = Data("not JSON".utf8)
            } else {
                var body = request.httpBody ?? Data()
                if let stream = request.httpBodyStream {
                    stream.open()
                    defer { stream.close() }
                    var bytes = [UInt8](repeating: 0, count: 1024)
                    while true {
                        let count = stream.read(&bytes, maxLength: bytes.count)
                        if count <= 0 { break }
                        body.append(contentsOf: bytes.prefix(count))
                    }
                }
                let echo: [String: Any] = [
                    "url": url.absoluteString, "method": request.httpMethod ?? "",
                    "accept": request.value(forHTTPHeaderField: "Accept") ?? "",
                    "contentType": request.value(forHTTPHeaderField: "Content-Type") ?? "",
                    "body": try JSONSerialization.jsonObject(with: body),
                ]
                let name = String(decoding: try JSONSerialization.data(withJSONObject: echo), as: UTF8.self)
                data = try JSONSerialization.data(withJSONObject: ["id": 51, "name": name])
            }
            let response = try XCTUnwrap(
                HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)
            )
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }

    override func stopLoading() {}
}
