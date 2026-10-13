import SwiftUI
import SwiftData

@main
struct Lab3App: App {
    let container = try! ModelContainer(for: NumberRecord.self)

    var body: some Scene {
        WindowGroup {
            MainView(storageService: StorageService(context: container.mainContext))
        }
    }
}
