import Foundation

protocol FavoritesViewProtocol:
    AnyObject {

    func showMovies(
        _ movies: [UserMovieData]
    )
}

protocol FavoritesPresenterProtocol:
    AnyObject {

    func viewWillAppear()
}

protocol FavoritesModelProtocol:
    AnyObject {

    func getFavorites() async
        -> [UserMovieData]
}
