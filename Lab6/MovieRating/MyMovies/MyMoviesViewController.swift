


import UIKit

final class MyMoviesViewController:
    UIViewController {

    private let presenter:
        MyMoviesPresenterProtocol

    private var movies:
        [UserMovieData] = []

    private let tableView =
        UITableView()

    init(
        presenter:
            MyMoviesPresenterProtocol
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
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        presenter.viewWillAppear()
    }

    private func setupUI() {
        title = "Мои фильмы"

        view.backgroundColor =
            .systemBackground

        navigationController?
            .navigationBar
            .prefersLargeTitles = true

        navigationItem
            .largeTitleDisplayMode = .always

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints =
            false

        tableView.dataSource = self

        tableView.rowHeight =
            UITableView.automaticDimension

        tableView.estimatedRowHeight =
            100

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
}

extension MyMoviesViewController:
    MyMoviesViewProtocol {

    func showMovies(
        _ movies: [UserMovieData]
    ) {
        self.movies = movies

        if movies.isEmpty {
            let label = UILabel()

            label.text =
                "Здесь появятся просмотренные фильмы, оценки и заметки"

            label.textAlignment =
                .center

            label.textColor =
                .secondaryLabel

            label.numberOfLines = 0

            tableView.backgroundView =
                label
        } else {
            tableView.backgroundView =
                nil
        }

        tableView.reloadData()
    }
}

extension MyMoviesViewController:
    UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        movies.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let identifier =
            "MyMovieCell"

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: identifier
            ) ??
            UITableViewCell(
                style: .subtitle,
                reuseIdentifier: identifier
            )

        let movie =
            movies[indexPath.row]

        cell.textLabel?.text =
            movie.title

        cell.textLabel?.font =
            .systemFont(
                ofSize: 18,
                weight: .semibold
            )

        cell.detailTextLabel?
            .numberOfLines = 0

        var details: [String] = []

        if movie.isWatched {
            details.append(
                "✓ Просмотрено"
            )
        }

        if let rating =
            movie.userRating {

            details.append(
                "Моя оценка: \(String(format: "%.1f", rating))"
            )
        }

        if !movie.note.isEmpty {
            details.append(
                "Заметка: \(movie.note)"
            )
        }

        cell.detailTextLabel?.text =
            details.joined(
                separator: "\n"
            )

        cell.detailTextLabel?.textColor =
            .secondaryLabel

        cell.imageView?.image =
            UIImage(
                systemName:
                    "person.text.rectangle"
            )

        cell.imageView?.tintColor =
            .systemBlue

        return cell
    }
}
