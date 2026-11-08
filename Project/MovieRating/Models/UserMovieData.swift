


import Foundation

struct UserMovieData: Equatable {
    let movieID: Int
    let title: String
    let year: Int
    let genre: String

    let isFavorite: Bool
    let isWatched: Bool

    let userRating: Double?
    let note: String

    let updatedAt: Date
}
