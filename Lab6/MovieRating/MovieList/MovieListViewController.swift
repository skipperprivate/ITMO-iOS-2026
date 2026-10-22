import UIKit

final class MovieListViewController:
    UIViewController {

    private let presenter:
        MovieListPresenterProtocol

    private let userMovieRepository:
        UserMovieRepositoryProtocol

    private let imageLoader:
        ImageLoaderProtocol

    private var movies:
        [Movie] = []

    private let tableView =
        UITableView()
    
    private let ratingService:
        TMDBRatingServiceProtocol
    
    init(
        presenter:
            MovieListPresenterProtocol,
        userMovieRepository:
            UserMovieRepositoryProtocol,
        imageLoader:
            ImageLoaderProtocol,
        ratingService:
            TMDBRatingServiceProtocol
    ) {
        self.presenter =
            presenter

        self.userMovieRepository =
            userMovieRepository

        self.imageLoader =
            imageLoader

        self.ratingService =
            ratingService

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

        presenter.viewDidLoad()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(
            animated
        )

        presenter.viewWillAppear()
    }

    private func setupUI() {
        title = "Фильмы"

        view.backgroundColor =
            .systemBackground

        navigationController?
            .navigationBar
            .prefersLargeTitles =
            true

        navigationItem
            .largeTitleDisplayMode =
            .always

        view.addSubview(
            tableView
        )

        tableView
            .translatesAutoresizingMaskIntoConstraints =
            false

        tableView.dataSource =
            self

        tableView.delegate =
            self

        tableView.rowHeight =
            100

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo:
                    view
                        .safeAreaLayoutGuide
                        .topAnchor
            ),

            tableView.leadingAnchor.constraint(
                equalTo:
                    view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo:
                    view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo:
                    view.bottomAnchor
            )
        ])
    }
}

extension MovieListViewController:
    MovieListViewProtocol {

    func showMovies(
        _ movies: [Movie]
    ) {
        self.movies =
            movies

        tableView.reloadData()
    }

    func showPoster(
        _ data: Data?,
        for movieID: Int
    ) {
        guard
            let index =
                movies.firstIndex(
                    where: {
                        $0.id == movieID
                    }
                )
        else {
            return
        }

        let indexPath =
            IndexPath(
                row: index,
                section: 0
            )

        guard let cell =
                tableView.cellForRow(
                    at: indexPath
                )
        else {
            return
        }

        if let data,
           let image =
                UIImage(
                    data: data
                ) {

            cell.imageView?.image =
                image

        } else {
            cell.imageView?.image =
                UIImage(
                    systemName:
                        "film"
                )
        }

        cell.imageView?.contentMode =
            .scaleAspectFill

        cell.imageView?.clipsToBounds =
            true

        cell.setNeedsLayout()
    }

    func showError(
        _ message: String
    ) {
        let alert =
            UIAlertController(
                title:
                    "Ошибка загрузки",
                message:
                    message,
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

    func openMovieDetail(
        _ movie: Movie
    ) {

        let viewController =
            MovieDetailAssembly.build(
                movie:
                    movie,
                userMovieRepository:
                    userMovieRepository,
                imageLoader:
                    imageLoader,
                ratingService:
                    ratingService
            )

        navigationController?
            .pushViewController(
                viewController,
                animated:
                    true
            )
    }
}

extension MovieListViewController:
    UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection
            section: Int
    ) -> Int {

        movies.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt
            indexPath: IndexPath
    ) -> UITableViewCell {

        let identifier =
            "MovieCell"

        let cell =
            tableView
                .dequeueReusableCell(
                    withIdentifier:
                        identifier
                )
            ??
            UITableViewCell(
                style:
                    .subtitle,
                reuseIdentifier:
                    identifier
            )

        let movie =
            movies[indexPath.row]

        cell.textLabel?.text =
            movie.title

        cell.textLabel?.font =
            .systemFont(
                ofSize: 18,
                weight:
                    .semibold
            )

        cell.detailTextLabel?.text =
            "\(movie.year) · \(movie.genre) · ★ \(String(format: "%.1f", movie.rating))"

        cell.detailTextLabel?
            .textColor =
            .secondaryLabel

        cell.imageView?.image =
            UIImage(
                systemName:
                    "film"
            )

        cell.imageView?.contentMode =
            .scaleAspectFill

        cell.imageView?.clipsToBounds =
            true

        cell.imageView?.tintColor =
            .systemBlue

        cell.accessoryType =
            .disclosureIndicator

        presenter.posterNeeded(
            at: indexPath.row
        )

        return cell
    }
}

extension MovieListViewController:
    UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt
            indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        presenter.didSelectMovie(
            at: indexPath.row
        )
    }
}
