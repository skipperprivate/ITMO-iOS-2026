import Foundation

final class FavoritesPresenter:
    FavoritesPresenterProtocol {

    weak var view:
        FavoritesViewProtocol?

    private let model:
        FavoritesModelProtocol

    init(
        model: FavoritesModelProtocol
    ) {
        self.model = model
    }

    func viewWillAppear() {

        Task { [weak self] in

            guard let self else {
                return
            }

            let movies =
                await model.getFavorites()

            await MainActor.run {
                self.view?.showMovies(
                    movies
                )
            }
        }
    }
}
