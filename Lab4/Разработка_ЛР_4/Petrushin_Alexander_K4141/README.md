# Лабораторная работа №4 — Петрушин Александр, К4141

## Назначение

Материалы выделены из проекта Weatherly и относятся к хранению пользовательских настроек и работе со списком избранных городов.

## Структура

- `Sources/Domain/Models/AppSettings.swift` — модель настроек и перечисления единиц измерения и темы.
- `Sources/Data/Repositories/UserDefaultsSettingsRepository.swift` — сохранение и загрузка настроек через `UserDefaults`.
- `Sources/App/SettingsStore.swift` — состояние настроек приложения.
- `Sources/Features/Settings/` — экран настроек и его ViewModel.
- `Sources/Domain/Repositories/SettingsRepositoryProtocol.swift` — контракт репозитория настроек.
- `Sources/Domain/Models/City.swift` — модель города.
- `Sources/Domain/Repositories/FavoritesRepositoryProtocol.swift` и `Sources/Data/Repositories/InMemoryFavoritesRepository.swift` — контракт и текущая реализация списка избранных городов.
- `Sources/Core/Persistence/PersistenceStack.swift` — файл-заготовка из исходного проекта.

## Текущее состояние реализации

Настройки сериализуются в JSON и сохраняются в `UserDefaults`. Список избранных городов в этой версии хранится в памяти (`InMemoryFavoritesRepository`). Реализация постоянного хранения избранного через SwiftData в исходном проекте отсутствует; `PersistenceStack.swift` пока пустой. Поэтому данный комплект отражает существующий код и не заявляет, что SwiftData уже реализована.

## Использование

Файлы являются частью проекта Weatherly и используют общие типы и компоненты приложения. Для запуска необходимо открыть основной `Weatherly.xcodeproj`; эта папка — выделенный комплект исходников для просмотра лабораторной, а не самостоятельное приложение.

## Проверка

Перед сдачей следует сверить фактические пункты задания с приведённой реализацией. Если задание требует постоянного хранения избранных городов в SwiftData, эта часть ещё не выполнена.
