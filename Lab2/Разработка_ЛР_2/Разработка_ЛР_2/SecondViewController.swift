import UIKit

class SecondViewController: UIViewController {

    // MARK: - UI Elements

    private let imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(
            systemName: "star.fill"
        )

        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()

        label.text = "Погода супер!"

        label.font = .systemFont(
            ofSize: 24,
            weight: .medium
        )

        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        title = "Второй экран"

        setupView()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupView() {

        view.addSubview(imageView)
        view.addSubview(textLabel)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Картинка

            imageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            imageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -50
            ),

            imageView.widthAnchor.constraint(
                equalToConstant: 150
            ),

            imageView.heightAnchor.constraint(
                equalToConstant: 150
            ),

            // Текст

            textLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: 30
            ),

            textLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            textLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            )
        ])
    }
}
