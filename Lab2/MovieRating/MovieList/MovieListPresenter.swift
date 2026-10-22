import Foundation

final class MovieListPresenter:
    MovieListPresenterProtocol {

    weak var view:
        MovieListViewProtocol?

    private let model:
        MovieListModelProtocol

    private var movies:
        [Movie] = []

    private var reloadTask:
        Task<Void, Never>?

    private var posterTasks:
        [Int: Task<Void, Never>] = [:]

    init(
        model: MovieListModelProtocol
    ) {
        self.model = model
    }

    deinit {
        reloadTask?.cancel()

        posterTasks.values.forEach {
            $0.cancel()
        }
    }

    func viewDidLoad() {
    }

    func viewWillAppear() {
        reloadMovies()
    }

    func didSelectMovie(
        at index: Int
    ) {
        guard
            movies.indices.contains(
                index
            )
        else {
            return
        }

        view?.openMovieDetail(
            movies[index]
        )
    }

    func posterNeeded(
        at index: Int
    ) {
        guard
            movies.indices.contains(
                index
            )
        else {
            return
        }

        let movie =
            movies[index]

        guard
            posterTasks[movie.id] == nil
        else {
            return
        }

        posterTasks[movie.id] =
            Task { [weak self] in

                guard let self
                else {
                    return
                }

                let data =
                    try? await model
                        .getPosterData(
                            for: movie
                        )

                guard
                    !Task.isCancelled
                else {
                    return
                }

                await MainActor.run {
                    self.view?
                        .showPoster(
                            data,
                            for: movie.id
                        )
                }

                posterTasks[movie.id] = nil
            }
    }

    private func reloadMovies() {
        reloadTask?.cancel()

        posterTasks.values.forEach {
            $0.cancel()
        }

        posterTasks.removeAll()

        reloadTask =
            Task { [weak self] in

                guard let self
                else {
                    return
                }

                do {
                    let movies =
                        try await model
                            .getMovies()

                    guard
                        !Task.isCancelled
                    else {
                        return
                    }

                    await MainActor.run {
                        self.movies =
                            movies

                        self.view?
                            .showMovies(
                                movies
                            )
                    }

                } catch is CancellationError {
                    return

                } catch {
                    guard
                        !Task.isCancelled
                    else {
                        return
                    }

                    await MainActor.run {
                        self.view?
                            .showError(
                                error
                                    .localizedDescription
                            )
                    }
                }
            }
    }
}
