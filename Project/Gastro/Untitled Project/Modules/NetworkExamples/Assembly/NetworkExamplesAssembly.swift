import SwiftUI

@MainActor
protocol NetworkExamplesAssembly {
    associatedtype Content: View

    func build(service: any NetworkExamplesService, navigator: any AppNavigating) -> Content
}
