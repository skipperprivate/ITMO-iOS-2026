# Lab6 — QuoteApp. Сетевой слой


## Архитектура сетевого взаимодействия

```
Presentation (ViewModel)
    ↓  UseCase
Domain (UseCase)
    ↓  Repository
Data (Repository)
    ↓  DTO + NetworkClient
Core (NetworkClient → URLSession)
    ↓  HTTP
dummyjson.com/api/quotes
```

## Компоненты сетевого слоя

### 1. Endpoint — декларация API-маршрутов

```swift
struct Endpoint {
    enum HTTPMethod: String { case get = "GET" }
    
    let path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
}
```

### 2. NetworkClient — универсальный HTTP-клиент

```swift
class NetworkClient: NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
```

### 3. APIError — типобезопасная система ошибок

```swift
enum APIError: LocalizedError, Equatable {
    case invalidURL
    case noInternet
    case timeout
    case transport(description: String)
    case badRequest(message: String?)       // 400
    case unauthorized                       // 401
    case forbidden                          // 403
    case notFound                           // 404
    case tooManyRequests(retryAfter: Int?)  // 429
    case serverError(status: Int)           // 500
    case decodingFailed(path: String, reason: String)
}
```

### 4. DTO — Data Transfer Objects

```swift
struct QuoteDTO: Decodable {
    let id: Int
    let quote: String
    let author: String
    
    func toDomain() -> Quote
}

struct QuoteListDTO: Decodable {
    let quotes: [QuoteDTO]
    let total, offset, limit: Int
    
    enum CodingKeys: String, CodingKey {
        case quotes, total, limit
        case offset = "skip"  // маппинг API-поля "skip" → "offset"
    }
}
```

### 5. Repository — адаптация сетевого слоя к Domain

```swift
protocol QuoteRepositoryProtocol {
    func fetchRandomQuote() async throws -> Quote
    func fetchQuotes(offset: Int, limit: Int) async throws -> [Quote]
}

class QuoteRepository: QuoteRepositoryProtocol {
    func fetchRandomQuote() async throws -> Quote {
        let dto: QuoteDTO = try await network.request(Endpoint(path: "/quotes/random"))
        return dto.toDomain()
    }
    
    func fetchQuotes(offset: Int, limit: Int) async throws -> [Quote] {
        let dto: QuoteListDTO = try await network.request(
            Endpoint(path: "/quotes", queryItems: [
                URLQueryItem(name: "skip", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ])
        )
        return dto.quotes.map { $0.toDomain() }
    }
}
```

### 6. UseCase — бизнес-логика

```swift
protocol FetchQuoteOfTheDayUseCaseProtocol {
    func execute() async throws -> Quote
}

final class FetchQuoteOfTheDayUseCase: FetchQuoteOfTheDayUseCaseProtocol {
    private let repository: QuoteRepositoryProtocol
    
    func execute() async throws -> Quote {
        try await repository.fetchRandomQuote()
    }
}
```

### 7. DIContainer — сборка зависимостей

```swift
@MainActor
final class DIContainer {
    private lazy var network: NetworkClientProtocol = NetworkClient()
    private lazy var quoteRepository: QuoteRepositoryProtocol = QuoteRepository(network: network)
    private lazy var fetchQuoteUseCase = FetchQuoteOfTheDayUseCase(repository: quoteRepository)
    
    func makeQuoteOfTheDayViewModel() -> QuoteOfTheDayViewModel {
        QuoteOfTheDayViewModel(fetchUseCase: fetchQuoteUseCase, ...)
    }
}
```

## API-эндпоинты

| Эндпоинт | Метод | Описание |
|----------|-------|----------|
| `/quotes/random` | GET | Случайная цитата |
| `/quotes?skip=0&limit=10` | GET | Список цитат с пагинацией |

**Base URL:** `https://dummyjson.com`

## Обработка ошибок

```
NetworkClient
    ↓  API-статус ≠ 2xx
APIError (badRequest, unauthorized, notFound, tooManyRequests, serverError...)
    ↓  маппинг URLError
APIError (noInternet, timeout, transport)
    ↓  маппинг DecodingError
APIError (decodingFailed(path, reason))
    ↓
ViewModel → errorMessage
    ↓
View → Alert / Toast
```

## Структура проекта

```
QuoteApp/
├── Core/
│   ├── Network/
│   │   ├── NetworkClient.swift      # HTTP-клиент
│   │   ├── APIError.swift           # Система ошибок
│   │   └── Endpoint.swift           # Декларация маршрутов
│   ├── CoreData/
│   │   └── CoreDataStack.swift      
│   ├── Theme/
│   │   └── ThemeStore.swift         
│   └── Storage/
│       └── UserDefaults.swift       
├── Domain/
│   ├── Models/
│   │   └── Quote.swift              # Доменная модель
│   └── UseCases/
│       ├── FetchQuoteOfTheDayUseCase.swift
│       ├── GetFavoritesUseCase.swift
│       └── ToggleFavoriteUseCase.swift
├── Data/
│   ├── DTO/
│   │   └── QuoteDTO.swift           # JSON-маппинг
│   ├── CoreData/
│   │   └── QuoteEntity+*.swift     
│   └── Repositories/
│       ├── QuoteRepositoryProtocol.swift
│       └── FavoritesRepositoryProtocol.swift
├── Presentation/
│   ├── QuoteOfTheDay/
│   ├── History/
│   ├── Favorites/
│   └── Settings/
└── DI/
    └── DIContainer.swift            # Сборка зависимостей
```