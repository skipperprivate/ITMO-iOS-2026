# Лабораторная работа №7 — Unit + UI тесты

**Выполнил:** Петрушин Александр, К4141

## Цель работы
Рассмотреть автоматизированное тестирование iOS-приложения Weatherly с использованием XCTest и XCUITest.

## Состав работы

### Unit-тесты (`WeatherlyTests`)
- `ViewModels/ViewModelTests.swift` — проверка состояний и сценариев ViewModel: загрузка, ошибки, обновление, поиск и работа со списком городов.
- `Networking/NetworkingTests.swift` — проверка формирования запросов, декодирования ответов, повторных попыток и обработки сетевых ошибок.
- `Networking/ConcurrencyLimiterTests.swift` — проверка ограничения параллельных операций и обработки отмены.
- `Repositories/RepositoryTests.swift` — проверка преобразования ответов Open-Meteo, геокодирования и параллельной загрузки.
- `Repositories/CoalescingWeatherRepositoryTests.swift` — проверка объединения одновременных запросов.
- `Mocks/TestMocks.swift` и `Fixtures/Fixtures.swift` — тестовые заглушки, моки и JSON-фикстуры.

### UI-тесты (`WeatherlyUITests`)
- `WeatherlyUITests.swift` — UI test target на базе XCTest/XCUIApplication, включая запуск приложения и измерение времени запуска.

## Запуск
Открыть проект Weatherly в Xcode, выбрать схему `Weatherly` и запустить тесты сочетанием `⌘U`.

Тестовые исходники приведены из проекта Weatherly без изменения логики приложения.
