import Foundation

enum FavoritesViewState: Equatable {
    case loading
    case loaded([FavoriteCity])
    case empty
    case error(message: String)
}
