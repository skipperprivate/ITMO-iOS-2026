

import Foundation

protocol SettingsViewProtocol: AnyObject {
    func showSettings(
        hideWatched: Bool
    )
}

protocol SettingsPresenterProtocol: AnyObject {
    func viewDidLoad()

    func hideWatchedChanged(
        _ value: Bool
    )
}

protocol SettingsModelProtocol: AnyObject {
    var hideWatched: Bool { get set }
}
