import Foundation

protocol MyMoviesViewProtocol:
    AnyObject {

    func showMovies(
        _ movies: [UserMovieData]
    )
}

protocol MyMoviesPresenterProtocol:
    AnyObject {

    func viewWillAppear()
}

protocol MyMoviesModelProtocol:
    AnyObject {

    func getPersonalMovies() async
        -> [UserMovieData]
}
