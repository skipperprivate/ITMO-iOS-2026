


import UIKit

enum SettingsAssembly {

    static func build(
        settings: AppSettings
    ) -> UIViewController {

        let model =
            SettingsModel(
                settings: settings
            )

        let presenter =
            SettingsPresenter(
                model: model
            )

        let viewController =
            SettingsViewController(
                presenter: presenter
            )

        presenter.view =
            viewController

        return viewController
    }
}
