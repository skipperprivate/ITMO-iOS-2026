import Foundation

protocol MovieServiceProtocol {
    func getMovies() async throws
        -> [Movie]
}
