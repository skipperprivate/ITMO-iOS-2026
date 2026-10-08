# Lab 5 - Ilin Fedor K4140

Фрагменты [Weatherly на commit 4bf26ab](https://github.com/barashik07/Weatherly/commit/4bf26ab2611e7efe995b07709689842473ea9f8a).

• [ConcurrencyLimiter.swift](ConcurrencyLimiter.swift): actor ограничивает число одновременных операций, ведет очередь и обрабатывает отмену.

• [WeatherRepositoryProtocol.swift](WeatherRepositoryProtocol.swift): TaskGroup конкурентно загружает погоду для нескольких городов и сохраняет входной порядок результатов.

• [snippets.md](snippets.md): `@concurrent` для декодирования и `@MainActor` для состояния интерфейса.

`WeatherRepositoryProtocol.swift` использует доменные модели Weatherly. Фрагменты в `snippets.md` предназначены для чтения и защиты. `async/await` само по себе не гарантирует выполнение на отдельном потоке.
