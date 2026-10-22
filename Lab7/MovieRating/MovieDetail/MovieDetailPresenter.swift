import Foundation

final class MovieDetailPresenter:
    MovieDetailPresenterProtocol {

    weak var view:
        MovieDetailViewProtocol?

    private let model:
        MovieDetailModelProtocol

    private var posterTask:
        Task<Void, Never>?

    private var ratingTask:
        Task<Void, Never>?

    init(
        model:
            MovieDetailModelProtocol
    ) {
        self.model =
            model
    }

    deinit {
        posterTask?.cancel()

        ratingTask?.cancel()
    }

    func viewDidLoad() {

        view?.showMovie(
            model.movie
        )

        reloadUserData()

        loadPoster()
    }

    func favoriteButtonTapped() {

        model.toggleFavorite()

        reloadUserData()
    }

    func watchedChanged(
        _ isWatched: Bool
    ) {

        model.setWatched(
            isWatched
        )

        reloadUserData()
    }

    func savePersonalData(
        note: String,
        ratingText: String
    ) {

        let normalizedRating =
            ratingText
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .replacingOccurrences(
                    of: ",",
                    with: "."
                )

        var rating: Double?

        if !normalizedRating.isEmpty {

            guard
                let value =
                    Double(
                        normalizedRating
                    )
            else {

                view?.showError(
                    "Оценка должна быть числом."
                )

                return
            }

            guard
                (0.5...10).contains(
                    value
                )
            else {

                view?.showError(
                    "Оценка должна быть от 0.5 до 10."
                )

                return
            }

            let doubled =
                value * 2

            guard
                doubled.rounded() ==
                doubled
            else {

                view?.showError(
                    "Оценка должна быть с шагом 0.5."
                )

                return
            }

            rating =
                value
        }

        model.savePersonalData(
            note:
                note,
            rating:
                rating
        )

        reloadUserData()

        guard
            let rating
        else {

            view?.showSavedMessage()

            return
        }

        sendRatingToTMDB(
            rating
        )
    }

    private func sendRatingToTMDB(
        _ rating: Double
    ) {

        ratingTask?.cancel()

        ratingTask =
            Task { [weak self] in

                guard
                    let self
                else {
                    return
                }

                do {

                    try await model
                        .sendRating(
                            rating
                        )

                    guard
                        !Task.isCancelled
                    else {
                        return
                    }

                    await MainActor.run {

                        self.view?
                            .showSavedMessage()
                    }

                } catch {

                    guard
                        !Task.isCancelled
                    else {
                        return
                    }

                    await MainActor.run {

                        self.view?
                            .showError(
                                """
                                Данные сохранены локально, но рейтинг не удалось отправить в TMDB.

                                \(error.localizedDescription)
                                """
                            )
                    }
                }
            }
    }

    private func loadPoster() {

        posterTask?.cancel()

        posterTask =
            Task { [weak self] in

                guard
                    let self
                else {
                    return
                }

                let data =
                    try? await model
                        .getPosterData()

                guard
                    !Task.isCancelled
                else {
                    return
                }

                await MainActor.run {

                    self.view?
                        .showPoster(
                            data
                        )
                }
            }
    }

    private func reloadUserData() {

        let data =
            model.getUserData()

        view?.showUserData(
            data
        )
    }
}
