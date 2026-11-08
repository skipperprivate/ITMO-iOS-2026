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
        case loaded(FunFactModel, isCached: Bool)
        case error(String)
        case empty(String)
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
                state = .empty("Подходящих фактов не найдено. Возможно, они скрыты настройками.")
                return
            }
            
            // изменение state приводит к обновлению интерфейса
            state = .loaded(fact, isCached: false)
            
            do {
                try await saveViewedFact.execute(   // передаём просмотренный факт на сохранение в локальное хранилище
                    filmId: filmId,
                    filmTitle: filmTitle,
                    fact: fact
                )
            } catch {
                print("Не удалось сохранить просмотренный факт: \(error)")
            }
        } catch let error as NetworkError {
            // При сетевой ошибке пробуем загрузить сохранённый факт.
            // Если его нет, показываем исходную сетевую ошибку.
            await loadViewedFact(fallbackMessage: error.userMessage)
            
        } catch {
            await loadViewedFact(fallbackMessage: "Что-то пошло не так")
        }
    }
    
    private func loadViewedFact(fallbackMessage: String) async {   // уже просмотренные факты, из локального хранилища
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
                // Нет локальных фактов - показываем исходную ошибку
                state = .error(fallbackMessage)
                return
            }
            
            // Если есть сохранённый факт — показываем его
            state = .loaded(
                FunFactModel(
                    text: fact.text,
                    type: fact.type,
                    isSpoiler: fact.isSpoiler
                ),
                isCached: true
            )
            
        } catch {
            // Не удалось получить данные из локального хранилища
            state = .error(fallbackMessage)
        }
    }
}
