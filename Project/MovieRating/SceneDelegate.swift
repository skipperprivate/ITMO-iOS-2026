import UIKit
import SwiftData

class SceneDelegate:
    UIResponder,
    UIWindowSceneDelegate {

    var window: UIWindow?

    private var modelContainer:
        ModelContainer?

    private var isUITesting: Bool {
        ProcessInfo.processInfo
            .arguments
            .contains("UITEST_MODE")
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions:
            UIScene.ConnectionOptions
    ) {

        guard let windowScene =
            scene as? UIWindowScene
        else {
            return
        }

        do {
            let container: ModelContainer

            if isUITesting {

                let configuration =
                    ModelConfiguration(
                        isStoredInMemoryOnly: true
                    )

                container = try ModelContainer(
                    for: UserMovieEntity.self,
                    configurations: configuration
                )

            } else {

                container = try ModelContainer(
                    for: UserMovieEntity.self
                )
            }

            modelContainer = container

            let repository =
                SwiftDataUserMovieRepository(
                    context: container.mainContext
                )

            let httpClient =
                URLSessionHTTPClient()

            let imageLoader =
                CachedImageLoader(
                    httpClient: httpClient
                )

            let accessToken =
                Bundle.main.object(
                    forInfoDictionaryKey:
                        "TMDBReadAccessToken"
                ) as? String ?? ""

            let configuration =
                TMDBConfiguration(
                    accessToken: accessToken
                )

            let movieService:
                MovieServiceProtocol

            if isUITesting {
                movieService = MockMovieService()
            } else {

                guard !accessToken.isEmpty else {
                    fatalError(
                        "TMDBReadAccessToken is missing"
                    )
                }

                movieService = TMDBMovieService(
                    configuration: configuration,
                    httpClient: httpClient
                )
            }

            let ratingService =
                TMDBRatingService(
                    configuration: configuration,
                    httpClient: httpClient
                )

            let tabBarController =
                createTabBarController(
                    repository: repository,
                    movieService: movieService,
                    imageLoader: imageLoader,
                    ratingService: ratingService
                )

            let window =
                UIWindow(
                    windowScene: windowScene
                )

            window.rootViewController =
                tabBarController

            self.window = window

            window.makeKeyAndVisible()

        } catch {

            fatalError(
                "SwiftData initialization error: \(error)"
            )
        }
    }

    private func createTabBarController(
        repository: UserMovieRepositoryProtocol,
        movieService: MovieServiceProtocol,
        imageLoader: ImageLoaderProtocol,
        ratingService: TMDBRatingServiceProtocol
    ) -> UITabBarController {

        let settings: AppSettings

        if isUITesting {

            let defaults = UserDefaults(
                suiteName: "MovieRating.UITests"
            )!

            defaults.set(
                false,
                forKey: "hideWatched"
            )

            settings = AppSettings(
                defaults: defaults
            )

        } else {
            settings = AppSettings()
        }

        let movieList =
            MovieListAssembly.build(
                userMovieRepository: repository,
                settings: settings,
                movieService: movieService,
                imageLoader: imageLoader,
                ratingService: ratingService
            )

        let movieNavigation =
            UINavigationController(
                rootViewController: movieList
            )

        movieNavigation.tabBarItem =
            UITabBarItem(
                title: "Фильмы",
                image: UIImage(
                    systemName: "film"
                ),
                selectedImage: UIImage(
                    systemName: "film.fill"
                )
            )

        let favorites =
            FavoritesAssembly.build(
                repository: repository
            )

        let favoritesNavigation =
            UINavigationController(
                rootViewController: favorites
            )

        favoritesNavigation.tabBarItem =
            UITabBarItem(
                title: "Избранное",
                image: UIImage(
                    systemName: "heart"
                ),
                selectedImage: UIImage(
                    systemName: "heart.fill"
                )
            )

        let myMovies =
            MyMoviesAssembly.build(
                repository: repository
            )

        let myMoviesNavigation =
            UINavigationController(
                rootViewController: myMovies
            )

        myMoviesNavigation.tabBarItem =
            UITabBarItem(
                title: "Мои фильмы",
                image: UIImage(
                    systemName:
                        "person.text.rectangle"
                ),
                selectedImage: UIImage(
                    systemName:
                        "person.text.rectangle.fill"
                )
            )

        let settingsViewController =
            SettingsAssembly.build(
                settings: settings
            )

        let settingsNavigation =
            UINavigationController(
                rootViewController:
                    settingsViewController
            )

        settingsNavigation.tabBarItem =
            UITabBarItem(
                title: "Настройки",
                image: UIImage(
                    systemName: "gearshape"
                ),
                selectedImage: UIImage(
                    systemName:
                        "gearshape.fill"
                )
            )

        let tabBarController =
            UITabBarController()

        tabBarController.viewControllers = [
            movieNavigation,
            favoritesNavigation,
            myMoviesNavigation,
            settingsNavigation
        ]

        return tabBarController
    }
}
