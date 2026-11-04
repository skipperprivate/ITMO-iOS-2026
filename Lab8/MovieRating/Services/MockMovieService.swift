import Foundation

final class MockMovieService:
    MovieServiceProtocol {

    func getMovies() async throws
        -> [Movie] {

        try await Task.sleep(
            nanoseconds:
                2_000_000_000
        )

        return [
            Movie(
                id: 1,
                title: "Интерстеллар",
                originalTitle:
                    "Interstellar",
                year: 2014,
                genre: "Фантастика",
                rating: 8.7,
                overview:
                    """
                    Группа исследователей отправляется через червоточину в космосе в попытке найти новый дом для человечества.
                    """,
                posterURL: nil
            ),
            Movie(
                id: 2,
                title: "Начало",
                originalTitle:
                    "Inception",
                year: 2010,
                genre: "Фантастика",
                rating: 8.8,
                overview:
                    """
                    Профессиональный вор умеет проникать в сны людей и похищать информацию из их подсознания.
                    """,
                posterURL: nil
            )
        ]
    }
}
