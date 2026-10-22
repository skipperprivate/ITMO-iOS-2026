

import Foundation

final class SettingsPresenter:
    SettingsPresenterProtocol {

    weak var view:
        SettingsViewProtocol?

    private let model:
        SettingsModelProtocol

    init(
        model: SettingsModelProtocol
    ) {
        self.model = model
    }

    func viewDidLoad() {
        view?.showSettings(
            hideWatched:
                model.hideWatched
        )
    }

    func hideWatchedChanged(
        _ value: Bool
    ) {
        model.hideWatched =
            value
    }
}
