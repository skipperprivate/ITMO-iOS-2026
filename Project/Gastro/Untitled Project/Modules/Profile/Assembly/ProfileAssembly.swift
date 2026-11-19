import SwiftUI

@MainActor
protocol ProfileAssembly {
    associatedtype Content: View

    func build(sessionStore: any ProfileSessionStore, navigator: any AppNavigating) -> Content
}
