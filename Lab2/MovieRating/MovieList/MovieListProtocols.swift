import Foundation

protocol MovieListViewProtocol:
    AnyObject {

    func showMovies(
        _ movies: [Movie]
    )

    func showPoster(
        _ data: Data?,
        for movieID: Int
    )

    func showError(
        _ message: String
    )

    func openMovieDetail(
        _ movie: Movie
    )
}

protocol MovieListPresenterProtocol:
    AnyObject {

    func viewDidLoad()

    func viewWillAppear()

    func didSelectMovie(
        at index: Int
    )

    func posterNeeded(
        at index: Int
    )
}

protocol MovieListModelProtocol:
    AnyObject {

    func getMovies() async throws
        -> [Movie]

    func getPosterData(
        for movie: Movie
    ) async throws -> Data?
}
