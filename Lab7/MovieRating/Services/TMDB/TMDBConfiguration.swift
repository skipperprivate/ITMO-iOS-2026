import Foundation

struct TMDBConfiguration {
    let accessToken: String

    let apiBaseURL =
        URL(
            string:
                "https://api.themoviedb.org/3"
        )!

    let imageBaseURL =
        URL(
            string:
                "https://image.tmdb.org/t/p/w500"
        )!
}
