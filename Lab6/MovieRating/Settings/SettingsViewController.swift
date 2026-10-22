


import UIKit

final class SettingsViewController:
    UIViewController {

    private let presenter:
        SettingsPresenterProtocol

    private let hideWatchedLabel =
        UILabel()

    private let hideWatchedSwitch =
        UISwitch()

    private let hideWatchedStack =
        UIStackView()

    private let stackView =
        UIStackView()

    init(
        presenter:
            SettingsPresenterProtocol
    ) {
        self.presenter = presenter

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupActions()

        presenter.viewDidLoad()
    }

    private func setupUI() {
        title = "Настройки"

        view.backgroundColor =
            .systemBackground

        navigationController?
            .navigationBar
            .prefersLargeTitles = true

        hideWatchedLabel.text =
            "Скрывать просмотренные"

        hideWatchedStack.axis =
            .horizontal

        hideWatchedStack.distribution =
            .equalSpacing

        hideWatchedStack.addArrangedSubview(
            hideWatchedLabel
        )

        hideWatchedStack.addArrangedSubview(
            hideWatchedSwitch
        )

        stackView.axis =
            .vertical

        stackView.spacing = 24

        stackView.addArrangedSubview(
            hideWatchedStack
        )

        view.addSubview(
            stackView
        )

        stackView.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor,
                constant: 32
            ),

            stackView.leadingAnchor.constraint(
                equalTo:
                    view.leadingAnchor,
                constant: 20
            ),

            stackView.trailingAnchor.constraint(
                equalTo:
                    view.trailingAnchor,
                constant: -20
            )
        ])
    }

    private func setupActions() {

        hideWatchedSwitch.addTarget(
            self,
            action:
                #selector(
                    hideWatchedChanged
                ),
            for: .valueChanged
        )
    }

    @objc
    private func hideWatchedChanged() {
        presenter.hideWatchedChanged(
            hideWatchedSwitch.isOn
        )
    }
}

extension SettingsViewController:
    SettingsViewProtocol {

    func showSettings(
        hideWatched: Bool
    ) {
        hideWatchedSwitch.isOn =
            hideWatched
    }
}
