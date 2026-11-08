


import UIKit

final class FavoritesViewController:
    UIViewController {

    private let presenter:
        FavoritesPresenterProtocol

    private var movies:
        [UserMovieData] = []

    private let tableView =
        UITableView()

    init(
        presenter:
            FavoritesPresenterProtocol
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
        title = "Избранное"

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
        tableView.rowHeight = 80

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

extension FavoritesViewController:
    FavoritesViewProtocol {

    func showMovies(
        _ movies: [UserMovieData]
    ) {
        self.movies = movies

        if movies.isEmpty {
            let label = UILabel()

            label.text =
                "Избранных фильмов пока нет"

            label.textAlignment =
                .center

            label.textColor =
                .secondaryLabel

            tableView.backgroundView =
                label
        } else {
            tableView.backgroundView =
                nil
        }

        tableView.reloadData()
    }
}

extension FavoritesViewController:
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
            "FavoriteCell"

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

        if let rating =
            movie.userRating {

            cell.detailTextLabel?.text =
                "\(movie.year) · \(movie.genre) · Моя оценка: \(String(format: "%.1f", rating))"
        } else {
            cell.detailTextLabel?.text =
                "\(movie.year) · \(movie.genre)"
        }

        cell.detailTextLabel?.textColor =
            .secondaryLabel

        cell.imageView?.image =
            UIImage(
                systemName: "heart.fill"
            )

        cell.imageView?.tintColor =
            .systemRed

        return cell
    }
}
