# Weatherly
 
iOS-приложение для просмотра погоды

# Команда

- Никита
- Фёдор
- Саша

## Стек
 
| Что | Кто |
|---|---|
| Язык | Swift |
| UI | SwiftUI |
| Платформа | iOS 17+ |
| Архитектура | MVVM |
| Хранение | SwiftData |
| Сеть | URLSession |
| Многопоточность | Swift Concurrency |
| Тесты | XCTest |
| API | [Open-Meteo](https://open-meteo.com) (Скорее всего) |

## Структура проекта
```
Weatherly/
├── App/
├── Core/
│   ├── Networking/
│   ├── Persistence/
│   └── Extensions/
├── Domain/
│   ├── Models/
│   └── Repositories/
├── Data/
│   ├── Remote/
│   ├── Local/
│   └── Repositories/
└── Features/
    ├── Favorites/
    ├── Search/
    ├── CityDetail/
    └── Settings/
 
WeatherlyTests/
├── Mocks/
├── Fixtures/
├── Networking/
├── Repositories/
└── ViewModels/
```

