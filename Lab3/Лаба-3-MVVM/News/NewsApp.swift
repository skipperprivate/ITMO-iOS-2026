import SwiftUI
 
@main
@MainActor
struct UniNewsApp: App {
 
    @StateObject private var newsFeedViewModel: NewsFeedViewModel
 
    init() {
 
        let remoteDataSource = DummyJSONNewsRemoteDataSource()
 
        let repository = DefaultNewsRepository(
            remoteDataSource: remoteDataSource
        )
 
        let getNewsUseCase = DefaultGetNewsUseCase(
            repository: repository
        )
 
        _newsFeedViewModel = StateObject(
            wrappedValue: NewsFeedViewModel(
                getNewsUseCase: getNewsUseCase
            )
        )
    }
 
    var body: some Scene {
 
        WindowGroup {
 
            NewsFeedView(
                viewModel: newsFeedViewModel
            )
        }
    }
}
