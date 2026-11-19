import UIKit

class ViewController: UIViewController {

    // MARK: - UI Elements

    private let numberLabel: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = .systemFont(ofSize: 60, weight: .bold)
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let randomButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(
            "Сгенерировать число",
            for: .normal
        )

        button.titleLabel?.font = .systemFont(
            ofSize: 18,
            weight: .medium
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let secondScreenButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(
            "Открыть второй экран",
            for: .normal
        )

        button.titleLabel?.font = .systemFont(
            ofSize: 18,
            weight: .medium
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        title = "Случайное число"

        setupView()
        setupActions()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupView() {

        view.addSubview(numberLabel)
        view.addSubview(randomButton)
        view.addSubview(secondScreenButton)
    }

    private func setupActions() {

        randomButton.addTarget(
            self,
            action: #selector(generateNumber),
            for: .touchUpInside
        )

        secondScreenButton.addTarget(
            self,
            action: #selector(openSecondScreen),
            for: .touchUpInside
        )
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Случайное число

            numberLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            numberLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -80
            ),

            numberLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            numberLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            // Кнопка генерации

            randomButton.topAnchor.constraint(
                equalTo: numberLabel.bottomAnchor,
                constant: 30
            ),

            randomButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            // Кнопка второго экрана

            secondScreenButton.topAnchor.constraint(
                equalTo: randomButton.bottomAnchor,
                constant: 20
            ),

            secondScreenButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }

    // MARK: - Actions

    @objc private func generateNumber() {

        let randomNumber = Int.random(in: 1...100)

        numberLabel.text = "\(randomNumber)"
    }

    @objc private func openSecondScreen() {

        let secondViewController = SecondViewController()

        navigationController?.pushViewController(
            secondViewController,
            animated: true
        )
    }
}
