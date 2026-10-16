import Foundation

@Observable
@MainActor
final class CityDetailViewModel {
    enum State {
        case loading
        case loaded(CityWeatherSnapshot)
        case failed(RepositoryError)
    }

    let city: City
    private(set) var state: State = .loading
    private(set) var refreshError: RepositoryError?
    private(set) var lastUpdated: Date?

    private let weatherRepository: WeatherRepositoryProtocol
    private let now: () -> Date
    @ObservationIgnored private var inFlight: Task<Void, Never>?

    init(city: City, weatherRepository: WeatherRepositoryProtocol, now: @escaping () -> Date = Date.init) {
        self.city = city
        self.weatherRepository = weatherRepository
        self.now = now
    }

    var snapshot: CityWeatherSnapshot? {
        if case .loaded(let snapshot) = state { return snapshot }
        return nil
    }

    var isStale: Bool {
        guard let lastUpdated else { return true }
        return !ForecastFreshness.isFresh(lastUpdated, now: now())
    }

    func loadIfNeeded() async {
        if snapshot == nil, let cached = await weatherRepository.cachedSnapshot(for: city), snapshot == nil {
            show(cached)
        }
        guard snapshot == nil || isStale else { return }
        await load(policy: .returnFreshCache)
    }

    func refresh() async {
        await load(policy: .reloadIgnoringCache)
    }

    func recoverAfterReconnect() async {
        let hasFailed = if case .failed = state { true } else { false }
        guard hasFailed || refreshError != nil else { return }
        await load(policy: .returnFreshCache)
    }

    private func load(policy: CachePolicy) async {
        if let inFlight {
            await inFlight.value
            return
        }
        let task = Task { await performLoad(policy: policy) }
        inFlight = task
        await task.value
        inFlight = nil
    }

    private func performLoad(policy: CachePolicy) async {
        if snapshot == nil { state = .loading }
        do {
            show(try await weatherRepository.snapshot(for: city, policy: policy))
            refreshError = nil
        } catch {
            let error = RepositoryError.from(error)
            if snapshot == nil {
                state = .failed(error)
            } else {
                refreshError = error
            }
        }
    }

    private func show(_ snapshot: CityWeatherSnapshot) {
        state = .loaded(snapshot)
        lastUpdated = snapshot.fetchedAt
    }
}
