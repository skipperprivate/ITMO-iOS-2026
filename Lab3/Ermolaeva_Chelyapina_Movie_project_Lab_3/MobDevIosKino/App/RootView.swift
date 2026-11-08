import SwiftUI

struct RootView: View {
    
    // Router хранит состояние навигации и сохраняется при обновлениях View
    @StateObject private var router = AppRouter() //в экземпляре класса можно следить за path
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FilmListView(
                viewModel: Self.makeFilmListViewModel(),
                onSelectFilm: { id in
                    router.push(.filmDetail(id: id)) // callback из FilmView с выбранным id + "Добавь маршрут на экран Деталей"
                }
            )
            // Сопоставление маршрута с экраном назначения
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .filmDetail(let id):
                    OneFilmView(
                        filmId: id,
                        onShowFunFact: {router.push(.funFact(id: id))
                        })
                    
                case .funFact(let id):
                    FunFactView(viewModel: Self.makeFunFactViewModel(filmId: id))
                }
                
            }
        }
    }
    
    // Фабричный метод: сборка ViewModel для экрана Списка фильмов и внедрение зависимостей (DI)
    private static func makeFilmListViewModel() -> FilmListViewModel {
        let service: FilmListServiceProtocol = MockFilmListService()
        let repository: FilmListRepository = FilmListRepositoryImpl(service: service)
        let useCase: GetFilmListUseCase = GetFilmListUseCaseImpl(repository: repository)
        return FilmListViewModel(getFilmList: useCase)
    }
    
    // Сборка зависимостей для получения фактов через API; Фабричный метод
    private static func makeFunFactViewModel(filmId: Int) -> FunFactViewModel {
        let service: NetworkService = NetworkServiceImpl(apiKey: AppConfig.kinopoiskAPIKey)
        let repository: FilmFactsRepository = FilmFactsRepositoryImpl(service: service)
        let useCase: GetFilmFactsUseCase = GetFilmFactsUseCaseImpl(repository: repository)
        return FunFactViewModel(getFilmFacts: useCase, filmId: filmId)
    }
}
