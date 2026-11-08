import UIKit

final class MovieDetailViewController:
    UIViewController {

    private let presenter:
        MovieDetailPresenterProtocol

    private let scrollView =
        UIScrollView()

    private let stackView =
        UIStackView()

    private let posterImageView =
        UIImageView()

    private let titleLabel =
        UILabel()

    private let originalTitleLabel =
        UILabel()

    private let movieRatingLabel =
        UILabel()

    private let infoLabel =
        UILabel()

    private let overviewTitleLabel =
        UILabel()

    private let overviewLabel =
        UILabel()

    private let favoriteButton =
        UIButton(type: .system)

    private let watchedLabel =
        UILabel()

    private let watchedSwitch =
        UISwitch()

    private let watchedStack =
        UIStackView()

    private let personalTitleLabel =
        UILabel()

    private let userRatingTextField =
        UITextField()

    private let noteTextView =
        UITextView()

    private let saveButton =
        UIButton(type: .system)

    init(
        presenter:
            MovieDetailPresenterProtocol
    ) {
        self.presenter =
            presenter

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
        view.backgroundColor =
            .systemBackground

        title =
            "О фильме"

        navigationItem
            .largeTitleDisplayMode =
            .never

        setupScrollView()
        setupStackView()
        setupElements()
    }

    private func setupScrollView() {
        view.addSubview(
            scrollView
        )

        scrollView
            .translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo:
                    view
                        .safeAreaLayoutGuide
                        .topAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo:
                    view.leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo:
                    view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor
            )
        ])
        scrollView.keyboardDismissMode = .onDrag
    }

    private func setupStackView() {
        scrollView.addSubview(
            stackView
        )

        stackView
            .translatesAutoresizingMaskIntoConstraints =
            false

        stackView.axis =
            .vertical

        stackView.spacing =
            14

        stackView.addArrangedSubview(
            posterImageView
        )

        stackView.addArrangedSubview(
            titleLabel
        )

        stackView.addArrangedSubview(
            originalTitleLabel
        )

        stackView.addArrangedSubview(
            movieRatingLabel
        )

        stackView.addArrangedSubview(
            infoLabel
        )

        stackView.addArrangedSubview(
            overviewTitleLabel
        )

        stackView.addArrangedSubview(
            overviewLabel
        )

        stackView.addArrangedSubview(
            favoriteButton
        )

        stackView.addArrangedSubview(
            watchedStack
        )

        stackView.addArrangedSubview(
            personalTitleLabel
        )

        stackView.addArrangedSubview(
            userRatingTextField
        )

        stackView.addArrangedSubview(
            noteTextView
        )

        stackView.addArrangedSubview(
            saveButton
        )

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo:
                    scrollView
                        .contentLayoutGuide
                        .topAnchor,
                constant: 20
            ),

            stackView.leadingAnchor.constraint(
                equalTo:
                    scrollView
                        .contentLayoutGuide
                        .leadingAnchor,
                constant: 20
            ),

            stackView.trailingAnchor.constraint(
                equalTo:
                    scrollView
                        .contentLayoutGuide
                        .trailingAnchor,
                constant: -20
            ),

            stackView.bottomAnchor.constraint(
                equalTo:
                    scrollView
                        .contentLayoutGuide
                        .bottomAnchor,
                constant: -20
            ),

            stackView.widthAnchor.constraint(
                equalTo:
                    scrollView
                        .frameLayoutGuide
                        .widthAnchor,
                constant: -40
            ),

            posterImageView.heightAnchor.constraint(
                equalToConstant:
                    180
            ),

            noteTextView.heightAnchor.constraint(
                equalToConstant:
                    120
            ),

            saveButton.heightAnchor.constraint(
                equalToConstant:
                    48
            )
        ])
    }

    private func setupElements() {
        posterImageView.image =
            UIImage(
                systemName:
                    "film.stack"
            )

        posterImageView.contentMode =
            .scaleAspectFill

        posterImageView.tintColor =
            .systemBlue

        posterImageView.backgroundColor =
            .secondarySystemBackground

        posterImageView.layer.cornerRadius =
            16

        posterImageView.clipsToBounds =
            true

        titleLabel.font =
            .systemFont(
                ofSize: 28,
                weight: .bold
            )

        titleLabel.numberOfLines =
            0

        originalTitleLabel.font =
            .systemFont(
                ofSize: 16
            )

        originalTitleLabel.textColor =
            .secondaryLabel

        movieRatingLabel.font =
            .systemFont(
                ofSize: 22,
                weight:
                    .semibold
            )

        movieRatingLabel.textColor =
            .systemOrange

        infoLabel.textColor =
            .secondaryLabel

        overviewTitleLabel.text =
            "Описание"

        overviewTitleLabel.font =
            .systemFont(
                ofSize: 22,
                weight: .bold
            )

        overviewLabel.font =
            .systemFont(
                ofSize: 17
            )

        overviewLabel.numberOfLines =
            0

        var favoriteConfiguration =
            UIButton.Configuration
                .tinted()

        favoriteConfiguration.title =
            "♡ Добавить в избранное"

        favoriteButton.configuration =
            favoriteConfiguration

        watchedLabel.text =
            "Просмотрено"

        watchedLabel.font =
            .systemFont(
                ofSize: 17,
                weight: .medium
            )

        watchedStack.axis =
            .horizontal

        watchedStack.distribution =
            .equalSpacing

        watchedStack.addArrangedSubview(
            watchedLabel
        )

        watchedStack.addArrangedSubview(
            watchedSwitch
        )

        personalTitleLabel.text =
            "Мои данные"

        personalTitleLabel.font =
            .systemFont(
                ofSize: 22,
                weight: .bold
            )

        userRatingTextField.placeholder =
            "Моя оценка от 0 до 10"

        userRatingTextField.keyboardType =
            .decimalPad

        userRatingTextField.borderStyle =
            .roundedRect

        noteTextView.font =
            .systemFont(
                ofSize: 16
            )

        noteTextView.layer.borderWidth =
            1

        noteTextView.layer.borderColor =
            UIColor
                .separator
                .cgColor

        noteTextView.layer.cornerRadius =
            8

        var saveConfiguration =
            UIButton.Configuration
                .filled()

        saveConfiguration.title =
            "Сохранить"

        saveButton.configuration =
            saveConfiguration
    }

    private func setupActions() {
        favoriteButton.addTarget(
            self,
            action:
                #selector(
                    favoriteButtonTapped
                ),
            for:
                .touchUpInside
        )

        watchedSwitch.addTarget(
            self,
            action:
                #selector(
                    watchedSwitchChanged
                ),
            for:
                .valueChanged
        )

        saveButton.addTarget(
            self,
            action:
                #selector(
                    saveButtonTapped
                ),
            for:
                .touchUpInside
        )
    }

    @objc
    private func favoriteButtonTapped() {
        presenter
            .favoriteButtonTapped()
    }

    @objc
    private func watchedSwitchChanged() {
        presenter.watchedChanged(
            watchedSwitch.isOn
        )
    }

    @objc
    private func saveButtonTapped() {
        presenter.savePersonalData(
            note:
                noteTextView.text,
            ratingText:
                userRatingTextField.text
                ?? ""
        )

        view.endEditing(
            true
        )
    }
}

extension MovieDetailViewController:
    MovieDetailViewProtocol {

    func showMovie(
        _ movie: Movie
    ) {
        posterImageView.image =
            UIImage(
                systemName:
                    "film.stack"
            )

        titleLabel.text =
            movie.title

        originalTitleLabel.text =
            movie.originalTitle

        movieRatingLabel.text =
            String(
                format:
                    "★ %.1f / 10",
                movie.rating
            )

        infoLabel.text =
            "\(movie.year) · \(movie.genre)"

        overviewLabel.text =
            movie.overview
    }

    func showPoster(
        _ data: Data?
    ) {
        guard
            let data,
            let image =
                UIImage(
                    data: data
                )
        else {
            posterImageView.image =
                UIImage(
                    systemName:
                        "film.stack"
                )

            return
        }

        posterImageView.image =
            image
    }

    func showUserData(
        _ data: UserMovieData?
    ) {
        let isFavorite =
            data?.isFavorite
            ?? false

        favoriteButton
            .configuration?
            .title =
            isFavorite
            ? "♥ В избранном"
            : "♡ Добавить в избранное"

        watchedSwitch.isOn =
            data?.isWatched
            ?? false

        if let rating =
            data?.userRating {

            userRatingTextField.text =
                String(
                    format:
                        "%.1f",
                    rating
                )

        } else {
            userRatingTextField.text =
                ""
        }

        noteTextView.text =
            data?.note
            ?? ""
    }

    func showError(
        _ message: String
    ) {
        let alert =
            UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle:
                    .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    func showSavedMessage() {
        let alert =
            UIAlertController(
                title:
                    "Сохранено",
                message:
                    "Данные о фильме сохранены",
                preferredStyle:
                    .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }
}
