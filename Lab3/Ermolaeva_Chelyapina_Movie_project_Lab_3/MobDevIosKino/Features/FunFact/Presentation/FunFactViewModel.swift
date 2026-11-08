import Foundation
import Combine 

// ViewModel работает на MainActor, чтобы безопасно обновлять состояние UI
@MainActor final class FunFactViewModel: ObservableObject {

    // возможные состояния экрана
    enum State: Equatable {
        case loading
        case loaded(FunFactModel)
        case error(String)
    }

    @Published private(set) var state: State = .loading // private - для setter

    private let getFilmFacts: GetFilmFactsUseCase
    private let filmId: Int

    init(getFilmFacts: GetFilmFactsUseCase, filmId: Int) {
        self.getFilmFacts = getFilmFacts
        self.filmId = filmId
    }

    func load() async {
        // запускаем первоначальную загрузку
        guard case .loading = state else { return }
        await fetch()
    }

    func retry() async {
        await fetch()
    }

    private func fetch() async {
        state = .loading
        do {
            let facts = try await getFilmFacts.getFacts(filmId: filmId)

            // выбираем случайный факт, исключая bloopers и спойлеры
            let fact = facts
                .filter { $0.type == .fact && !$0.isSpoiler }
                .randomElement()

            guard let fact else {
                state = .error("Факты не найдены")
                return
            }

            // изменение state приводит к обновлению интерфейса
            state = .loaded(fact)

        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
