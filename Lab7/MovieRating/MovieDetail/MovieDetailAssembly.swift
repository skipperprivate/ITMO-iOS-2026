import UIKit

enum MovieDetailAssembly {

    static func build(
        movie: Movie,
        userMovieRepository:
            UserMovieRepositoryProtocol,
        imageLoader:
            ImageLoaderProtocol,
        ratingService:
            TMDBRatingServiceProtocol
    ) -> UIViewController {

        let model =
            MovieDetailModel(
                movie: movie,
                userMovieRepository:
                    userMovieRepository,
                imageLoader:
                    imageLoader,
                ratingService:
                    ratingService
            )

        let presenter =
            MovieDetailPresenter(
                model: model
            )

        let viewController =
            MovieDetailViewController(
                presenter:
                    presenter
            )

        presenter.view =
            viewController

        return viewController
    }
}
