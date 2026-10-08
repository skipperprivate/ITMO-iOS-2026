# Фрагменты кода

## Декодирование вне executor вызывающего actor

[NetworkClient.swift, строки 91-101](https://github.com/barashik07/Weatherly/blob/4bf26ab2611e7efe995b07709689842473ea9f8a/Weatherly/Core/Networking/NetworkClient.swift#L91-L101)

```swift
// Decoding a 10-day forecast is the heaviest step, so it runs off the caller's actor.
@concurrent
private static func decode<Response: Decodable>(_ type: Response.Type, from data: Data) async throws -> Response {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch let error as DecodingError {
        throw NetworkError.decodingFailed(error.summary)
    } catch {
        throw NetworkError.decodingFailed(error.localizedDescription)
    }
}
```

## Обновление состояния интерфейса

[PlacesViewModel.swift, строки 17-19 и 77-104](https://github.com/barashik07/Weatherly/blob/4bf26ab2611e7efe995b07709689842473ea9f8a/Weatherly/Features/Places/PlacesViewModel.swift#L17-L104). Метод находится в классе `PlacesViewModel`, помеченном `@Observable` и `@MainActor`.

```swift
func refreshWeather(policy: CachePolicy = .returnFreshCache) async {
    let requested = cities
    guard !requested.isEmpty else { return }
    for city in requested where !isLoaded(city) {
        weather[city.id] = .loading
    }
    do {
        let snapshots = try await weatherRepository.snapshots(for: requested, policy: policy)
        let byID = Dictionary(snapshots.map { ($0.city.id, $0.current) }, uniquingKeysWith: { first, _ in first })
        for city in requested {
            if let current = byID[city.id] {
                weather[city.id] = .loaded(current)
            } else if !isLoaded(city) {
                weather[city.id] = .unavailable
            }
        }
        weatherError = nil
    } catch is CancellationError {
        for city in requested where !isLoaded(city) {
            weather[city.id] = nil
        }
    } catch {
        for city in requested where !isLoaded(city) {
            weather[city.id] = .unavailable
        }
        weatherError = RepositoryError.from(error)
    }
}
```
