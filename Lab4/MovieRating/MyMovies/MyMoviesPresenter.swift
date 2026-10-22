import Foundation

final class MyMoviesPresenter:
    MyMoviesPresenterProtocol {

    weak var view:
        MyMoviesViewProtocol?

    private let model:
        MyMoviesModelProtocol

    init(
        model: MyMoviesModelProtocol
    ) {
        self.model = model
    }

    func viewWillAppear() {

        Task { [weak self] in

            guard let self else {
                return
            }

            let movies =
                await model.getPersonalMovies()

            await MainActor.run {
                self.view?.showMovies(
                    movies
                )
            }
        }
    }
}
