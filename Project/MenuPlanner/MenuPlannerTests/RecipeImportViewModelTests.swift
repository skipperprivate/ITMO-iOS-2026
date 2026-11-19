import XCTest
@testable import MenuPlanner

@MainActor
final class RecipeImportViewModelTests: CatalogTestCase {
    func testBlankQueryDoesNotRequestNetwork() async {
        let model = RecipeImportViewModel(catalog: catalog)
        await model.load(" \n ", page: 1)
        XCTAssertTrue(model.recipes.isEmpty)
        XCTAssertFalse(model.hasMore)
        XCTAssertFalse(model.hasError)
        XCTAssertFalse(model.isLoading)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testFirstPageTrimsAndLimitsQueryAndReplacesPreviousResults() async throws {
        let model = RecipeImportViewModel(catalog: catalog)
        serveTool(["items": [recipeJSON()], "meta": ["has_more": true]])
        await model.load("каша", page: 1)
        XCTAssertEqual(model.recipes.map(\.id), [1])
        XCTAssertTrue(model.hasMore)
        serveTool(["items": [recipeJSON(2)], "meta": ["has_more": false]])
        await model.load("  " + String(repeating: "я", count: 300) + "  ", page: 1)
        XCTAssertEqual(model.recipes.map(\.id), [2])
        XCTAssertFalse(model.hasMore)
        XCTAssertFalse(model.isLoading)
        let body = try Self.body(of: XCTUnwrap(StubURLProtocol.requests.last))
        let args = (body["params"] as? [String: Any])?["arguments"] as? [String: Any]
        XCTAssertEqual((args?["q"] as? String)?.count, 255)
        await model.load("", page: 1)
        XCTAssertTrue(model.recipes.isEmpty)
        XCTAssertFalse(model.hasMore)
    }

    func testPaginationDeduplicatesWithinAndAcrossPages() async {
        let model = RecipeImportViewModel(catalog: catalog)
        serveTool(["items": [recipeJSON(), recipeJSON()], "meta": ["has_more": true]])
        await model.load("каша", page: 1)
        serveTool(["items": [recipeJSON(), recipeJSON(2), recipeJSON(2)], "meta": ["has_more": false]])
        await model.load("каша", page: 2)
        XCTAssertEqual(model.recipes.map(\.id), [1, 2])
        XCTAssertFalse(model.hasMore)
    }

    func testFailedSecondPageKeepsResultsAndCanBeRetried() async {
        let model = RecipeImportViewModel(catalog: catalog)
        serveTool(["items": [recipeJSON()], "meta": ["has_more": true]])
        await model.load("каша", page: 1)
        StubURLProtocol.configure { _ in throw URLError(.timedOut) }
        await model.load("каша", page: 2)
        XCTAssertTrue(model.hasError)
        XCTAssertFalse(model.isLoading)
        XCTAssertEqual(model.recipes.map(\.id), [1])
        serveTool(["items": [recipeJSON(2)], "meta": ["has_more": false]])
        await model.load("каша", page: 2)
        XCTAssertFalse(model.hasError)
        XCTAssertEqual(model.recipes.map(\.id), [1, 2])
    }

    func testCancellationBeforeLoadingDoesNotChangeStateOrStartHTTP() async {
        let model = RecipeImportViewModel(catalog: catalog)
        let task = Task { await model.load("каша", page: 1) }
        task.cancel()
        await task.value
        XCTAssertFalse(model.hasError)
        XCTAssertFalse(model.isLoading)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testCancellationDuringDebounceDoesNotShowError() async throws {
        let model = RecipeImportViewModel(catalog: catalog)
        let task = Task { await model.load("каша", page: 1) }
        await Task.yield()
        task.cancel()
        await task.value
        XCTAssertFalse(model.hasError)
        XCTAssertTrue(model.recipes.isEmpty)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
        // Clearing the search resets the loading state after a cancelled request.
        await model.load("", page: 1)
        XCTAssertFalse(model.isLoading)
    }
}
