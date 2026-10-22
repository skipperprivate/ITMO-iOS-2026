


import Foundation
import SwiftData

@Model
final class UserMovieEntity {

    @Attribute(.unique)
    var movieID: Int

    var title: String
    var year: Int
    var genre: String

    var isFavorite: Bool
    var isWatched: Bool

    var userRating: Double?
    var note: String

    var updatedAt: Date

    init(
        movieID: Int,
        title: String,
        year: Int,
        genre: String,
        isFavorite: Bool = false,
        isWatched: Bool = false,
        userRating: Double? = nil,
        note: String = ""
    ) {
        self.movieID = movieID
        self.title = title
        self.year = year
        self.genre = genre
        self.isFavorite = isFavorite
        self.isWatched = isWatched
        self.userRating = userRating
        self.note = note
        self.updatedAt = Date()
    }
}
