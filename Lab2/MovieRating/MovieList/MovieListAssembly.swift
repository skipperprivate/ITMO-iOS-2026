import UIKit

enum MovieListAssembly {

    static func build(
        userMovieRepository:
            UserMovieRepositoryProtocol,
        settings:
            AppSettings,
        movieService:
            MovieServiceProtocol,
        imageLoader:
            ImageLoaderProtocol,
        ratingService:
            TMDBRatingServiceProtocol
    ) -> UIViewController {

        let model =
            MovieListModel(
                settings:
                    settings,
                userMovieRepository:
                    userMovieRepository,
                movieService:
                    movieService,
                imageLoader:
                    imageLoader
            )

        let presenter =
            MovieListPresenter(
                model:
                    model
            )

        let viewController =
            MovieListViewController(
                presenter:
                    presenter,
                userMovieRepository:
                    userMovieRepository,
                imageLoader:
                    imageLoader,
                ratingService:
                    ratingService
            )

        presenter.view =
            viewController

        return viewController
    }
}
