import Foundation
import SwiftData


final class SwiftDataUserMovieRepository:
    UserMovieRepositoryProtocol {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getData(
        for movieID: Int
    ) -> UserMovieData? {

        guard let entity = findEntity(
            movieID: movieID
        ) else {
            return nil
        }

        return map(entity)
    }

    func toggleFavorite(
        for movie: Movie
    ) {

        let entity = getOrCreateEntity(
            for: movie
        )

        entity.isFavorite.toggle()
        entity.updatedAt = Date()

        save()
    }

    func setWatched(
        _ isWatched: Bool,
        for movie: Movie
    ) {

        let entity = getOrCreateEntity(
            for: movie
        )

        entity.isWatched = isWatched
        entity.updatedAt = Date()

        save()
    }

    func savePersonalData(
        note: String,
        rating: Double?,
        for movie: Movie
    ) {

        let entity = getOrCreateEntity(
            for: movie
        )

        entity.note = note
        entity.userRating = rating
        entity.updatedAt = Date()

        save()
    }

    func getFavorites() async -> [UserMovieData] {

        let descriptor = FetchDescriptor<UserMovieEntity>(
            predicate: #Predicate { movie in
                movie.isFavorite == true
            },
            sortBy: [
                SortDescriptor(
                    \.updatedAt,
                    order: .reverse
                )
            ]
        )

        do {
            return try context
                .fetch(descriptor)
                .map(map)
        } catch {
            print(
                "SwiftData favorites fetch error: \(error)"
            )

            return []
        }
    }

    func getPersonalMovies() async -> [UserMovieData] {

        let descriptor = FetchDescriptor<UserMovieEntity>(
            sortBy: [
                SortDescriptor(
                    \.updatedAt,
                    order: .reverse
                )
            ]
        )

        do {
            return try context
                .fetch(descriptor)
                .filter {
                    $0.isWatched ||
                    $0.userRating != nil ||
                    !$0.note.isEmpty
                }
                .map(map)
        } catch {
            print(
                "SwiftData personal movies fetch error: \(error)"
            )

            return []
        }
    }

    func getWatchedMovieIDs() -> Set<Int> {

        let descriptor = FetchDescriptor<UserMovieEntity>(
            predicate: #Predicate { movie in
                movie.isWatched == true
            }
        )

        do {
            let entities = try context.fetch(
                descriptor
            )

            return Set(
                entities.map {
                    $0.movieID
                }
            )
        } catch {
            return []
        }
    }

    private func findEntity(
        movieID: Int
    ) -> UserMovieEntity? {

        let id = movieID

        var descriptor = FetchDescriptor<UserMovieEntity>(
            predicate: #Predicate { movie in
                movie.movieID == id
            }
        )

        descriptor.fetchLimit = 1

        do {
            return try context.fetch(
                descriptor
            ).first
        } catch {
            return nil
        }
    }

    private func getOrCreateEntity(
        for movie: Movie
    ) -> UserMovieEntity {

        if let entity = findEntity(
            movieID: movie.id
        ) {
            return entity
        }

        let entity = UserMovieEntity(
            movieID: movie.id,
            title: movie.title,
            year: movie.year,
            genre: movie.genre
        )

        context.insert(entity)

        return entity
    }

    private func map(
        _ entity: UserMovieEntity
    ) -> UserMovieData {

        UserMovieData(
            movieID: entity.movieID,
            title: entity.title,
            year: entity.year,
            genre: entity.genre,
            isFavorite: entity.isFavorite,
            isWatched: entity.isWatched,
            userRating: entity.userRating,
            note: entity.note,
            updatedAt: entity.updatedAt
        )
    }

    private func save() {

        do {
            try context.save()
        } catch {
            print(
                "SwiftData save error: \(error)"
            )
        }
    }
}
