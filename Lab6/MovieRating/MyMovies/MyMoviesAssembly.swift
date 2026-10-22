


import UIKit

enum MyMoviesAssembly {

    static func build(
        repository:
            UserMovieRepositoryProtocol
    ) -> UIViewController {

        let model =
            MyMoviesModel(
                repository: repository
            )

        let presenter =
            MyMoviesPresenter(
                model: model
            )

        let viewController =
            MyMoviesViewController(
                presenter: presenter
            )

        presenter.view =
            viewController

        return viewController
    }
}
