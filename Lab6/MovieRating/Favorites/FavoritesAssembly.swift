


import UIKit

enum FavoritesAssembly {

    static func build(
        repository:
            UserMovieRepositoryProtocol
    ) -> UIViewController {

        let model =
            FavoritesModel(
                repository: repository
            )

        let presenter =
            FavoritesPresenter(
                model: model
            )

        let viewController =
            FavoritesViewController(
                presenter: presenter
            )

        presenter.view =
            viewController

        return viewController
    }
}
