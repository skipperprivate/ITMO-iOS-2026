import Foundation

struct TMDBMovieListResponse:
    Decodable {

    let results: [TMDBMovieDTO]
}

struct TMDBMovieDTO:
    Decodable {

    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: String?
    let voteAverage: Double
    let genreIDs: [Int]
    let posterPath: String?

    enum CodingKeys:
        String,
        CodingKey {

        case id
        case title
        case overview

        case originalTitle =
            "original_title"

        case releaseDate =
            "release_date"

        case voteAverage =
            "vote_average"

        case genreIDs =
            "genre_ids"

        case posterPath =
            "poster_path"
    }
}
