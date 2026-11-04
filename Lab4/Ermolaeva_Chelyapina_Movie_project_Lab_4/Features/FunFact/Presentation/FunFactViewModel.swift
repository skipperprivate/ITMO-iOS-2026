import Foundation
import Combine

// ViewModel работает на MainActor, чтобы безопасно обновлять состояние UI
@MainActor
final class FunFactViewModel: ObservableObject {

    // возможные состояния экрана
    @Published private(set) var state: State = .loading // private - для setter

    // local storage
    private let saveViewedFact: SaveViewedFunFactUseCase
    private let getViewedFacts: GetViewedFactsUseCase
    private let getFilmFacts: GetFilmFactsUseCase
    private let settings: UserDefaultsSettings
    private let filmId: Int
    private let filmTitle: String
    
    enum State: Equatable {
        case loading
        case loaded(FunFactModel)
        case error(String)
    }
    
    init(
        getFilmFacts: GetFilmFactsUseCase,
         filmId: Int,
         filmTitle: String,
         settings: UserDefaultsSettings,
         saveViewedFact: SaveViewedFunFactUseCase,
         getViewedFacts: GetViewedFactsUseCase
    ) {
        self.getFilmFacts = getFilmFacts
        self.filmId = filmId
        self.filmTitle = filmTitle
        self.settings = settings
        self.saveViewedFact = saveViewedFact
        self.getViewedFacts = getViewedFacts
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
                .filter { fact in
                    fact.type == .fact &&
                    (!settings.hideSpoilers || !fact.isSpoiler)
                }
                .randomElement()

            guard let fact else {
                state = .error("Факты не найдены")
                return
            }

            // изменение state приводит к обновлению интерфейса
            state = .loaded(fact)

            do {
                try await saveViewedFact.execute(   // передаём просмотренный факт на сохранение в локальное хранилище
                    filmId: filmId,
                    filmTitle: filmTitle,
                    fact: fact
                )
            } catch {
                print("Не удалось сохранить просмотренный факт: \(error)")
            }
        } catch {
            await loadViewedFact()  
        }
    }
    
    private func loadViewedFact() async {   // уже просмотренные факты, из локального хранилища
        do {
            let facts = try await getViewedFacts.execute()

            let fact = facts
                .filter { fact in
                    fact.filmId == filmId &&
                    fact.type == .fact &&
                    (!settings.hideSpoilers || !fact.isSpoiler)
                }
                .randomElement()

            guard let fact else {
                state = .error("Нет сохранённых фактов")
                return
            }

            state = .loaded(
                FunFactModel(
                    text: fact.text,
                    type: fact.type,
                    isSpoiler: fact.isSpoiler
                )
            )
        } catch {
            state = .error("Не удалось загрузить сохранённые факты")
        }
    }
}
