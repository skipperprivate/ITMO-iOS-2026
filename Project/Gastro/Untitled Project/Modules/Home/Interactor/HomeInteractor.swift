import Combine
import Foundation

@MainActor
protocol HomeInteractor {
    func recipeCount() throws -> Int
}
