import Foundation

struct TMDBMovieMapper {

    private let imageBaseURL: URL

    init(
        imageBaseURL: URL
    ) {
        self.imageBaseURL =
            imageBaseURL
    }

    func map(
        _ dto: TMDBMovieDTO
    ) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            originalTitle:
                dto.originalTitle,
            year:
                year(
                    from:
                        dto.releaseDate
                ),
            genre:
                genreName(
                    from:
                        dto.genreIDs
                ),
            rating:
                dto.voteAverage,
            overview:
                dto.overview.isEmpty
                ? "Описание отсутствует."
                : dto.overview,
            posterURL:
                posterURL(
                    from:
                        dto.posterPath
                )
        )
    }

    private func year(
        from releaseDate: String?
    ) -> Int {
        guard
            let releaseDate,
            releaseDate.count >= 4
        else {
            return 0
        }

        return Int(
            releaseDate.prefix(4)
        ) ?? 0
    }

    private func posterURL(
        from posterPath: String?
    ) -> URL? {
        guard let posterPath
        else {
            return nil
        }

        return imageBaseURL
            .appendingPathComponent(
                posterPath
                    .trimmingCharacters(
                        in:
                            CharacterSet(
                                charactersIn: "/"
                            )
                    )
            )
    }

    private func genreName(
        from genreIDs: [Int]
    ) -> String {
        let names =
            genreIDs.compactMap {
                genreNames[$0]
            }

        guard !names.isEmpty
        else {
            return "Жанр не указан"
        }

        return names
            .prefix(2)
            .joined(
                separator: ", "
            )
    }

    private let genreNames:
        [Int: String] = [
            28: "Боевик",
            12: "Приключения",
            16: "Анимация",
            35: "Комедия",
            80: "Криминал",
            99: "Документальный",
            18: "Драма",
            10751: "Семейный",
            14: "Фэнтези",
            36: "История",
            27: "Ужасы",
            10402: "Музыка",
            9648: "Детектив",
            10749: "Мелодрама",
            878: "Фантастика",
            10770: "ТВ-фильм",
            53: "Триллер",
            10752: "Военный",
            37: "Вестерн"
        ]
}
