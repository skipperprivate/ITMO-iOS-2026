import Foundation

protocol TMDBRatingServiceProtocol:
    AnyObject {

    func rateMovie(
        movieID: Int,
        value: Double
    ) async throws
}
