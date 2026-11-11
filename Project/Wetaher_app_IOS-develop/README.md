# 🌤️ Weather App iOS (Wetaher_app_IOS)

> **Платформа:** iOS 17.0+ | **Язык:** Swift 5.9+ | **UI-фреймворк:** SwiftUI | **Архитектура:** MVVM.

Приложение для просмотра текущей погоды: карточка с текущей температурой, почасовой прогноз,
прогноз на 7 дней и сетка метрик — ветер, давление, влажность, УФ-индекс, восход/закат, видимость.
Есть список избранных городов с поиском и добавлением, а также экран настроек с переключением темы.

```
Wetaher_app_IOS/
├── App/
│   └── WeatherApp.swift                    # Точка входа (@main), создание AppNavStack
│
├── Domain/
│   └── WeatherRepository.swift             # Протокол репозитория: погода, поиск и избранные города
│
├── Data/
│   ├── WeatherRepositoryImpl.swift         # Реализация репозитория
│   └── Network/
│       └── NetworkClient.swift             # HTTP-клиент к API погоды
│
├── Mappers/
│   ├── CityErrorResponseMapper.swift       # Ответ с ошибкой поиска → CityErrorUI
│   ├── CityResponseMapper.swift            # Ответ API → City
│   ├── WeatherErrorResponseMapper.swift    # Ответ с ошибкой погоды → WeatherErrorUI
│   └── WeatherResponseMapper.swift         # Ответ API → модель погоды + ForecastUI
│
├── Models/
│   ├── Data/
│   │   └── Network/
│   │       ├── City/                       # DTO поиска городов
│   │       │   ├── CityResponse.swift
│   │       │   ├── CityResponseError.swift
│   │       │   ├── NoCitiesResponse.swift
│   │       │   └── PossibleCitiesResponse.swift
│   │       └── Weather/                    # DTO прогноза погоды
│   │           ├── CurrentWeatherResponse.swift
│   │           ├── DailyWeatherResponse.swift
│   │           ├── HourlyWeatherResponse.swift
│   │           ├── WeatherErrorResponse.swift
│   │           └── WeatherResponse.swift
│   └── UI/
│       ├── AppThemeProps.swift             # Тема приложения: системная / светлая / тёмная
│       ├── City.swift                      # Модель города
│       ├── CityErrorUI.swift               # Ошибка поиска + резервные города
│       ├── CityWeatherState.swift          # Выбранный город: новый или уже с погодой
│       └── Weather/
│           ├── CurrentWeather.swift        # Текущая погода
│           ├── DailyWeather.swift          # Дневной прогноз (min/max, восход/закат)
│           ├── ForecastUI.swift            # Агрегат прогноза для UI
│           ├── HourlyWeather.swift         # Почасовой прогноз
│           ├── UVStatus.swift              # Описание и цвет УФ-индекса
│           ├── WeatherCondition.swift      # Код погоды: описание, SF Symbol, цвета фона
│           └── WeatherErrorUI.swift        # Ошибка загрузки погоды для UI
│
├── UI/
│   ├── AppNavStack.swift                   # Корневой экран: роутинг, sheets, тема, зависимости
│   ├── Helpers/
│   │   ├── CityUIHelper.swift              # Преобразования для списка городов
│   │   ├── MetricFormatter.swift           # Форматирование температуры, давления, скорости ветра
│   │   └── WeatherUIHelper.swift           # Статусы, направления ветра, даты и время
│   ├── ScreenState/
│   │   ├── AddCityUiState.swift            # Состояния экрана добавления города
│   │   ├── CityListUIState.swift           # Состояния списка избранных городов
│   │   ├── WeatherError.swift              # Экран ошибки с кнопкой «Повторить»
│   │   ├── WeatherSuccess.swift            # Экран с контентом и кнопками настроек/городов
│   │   └── WeatherUIState.swift            # Состояния главного экрана
│   └── Pages/
│       ├── Main/
│       │   ├── WeatherMainView.swift       # Скролл-контейнер и сетка метрик
│       │   ├── WeatherMainViewModel.swift  # Загрузка и обновление прогноза
│       │   └── Components/
│       │       ├── CurrentWeatherHeader.swift  # Город, статус, температура, ощущается как
│       │       ├── DailyForecast.swift         # Прогноз на 7 дней
│       │       ├── HourlyForecast.swift        # Карусель почасового прогноза
│       │       ├── WeatherBackground.swift     # Градиентный фон под погоду и тему
│       │       └── WeatherMetricCard.swift     # Карточки метрик
│       ├── Cities/
│       │   ├── AddCityView.swift           # Поиск и добавление городов
│       │   ├── CityListView.swift          # Список избранных городов
│       │   ├── CityListViewModel.swift     # Избранные города, поиск с debounce, ошибки
│       │   └── Components/
│       │       └── CityCard.swift          # Карточка города в списке
│       └── Settings/
│           ├── SettingsView.swift          # Настройки: тема и единицы измерения
│           └── SettingsViewModel.swift     # Хранение выбранной темы
│
├── Resources/
│   ├── Assets/
│   │   └── BaseAssets.swift                # Моковые города и прогнозы
│   ├── Colors/
│   │   ├── BaseColors.swift                # Системные оттенки и градиенты погоды
│   │   └── Colors.swift                    # Семантические цвета интерфейса
│   └── Constants/
│       ├── BaseNumeral.swift               # Отступы, интервалы, размеры, шрифты, прозрачность
│       └── BaseText.swift                  # Строки интерфейса (задел под локализацию)
│
└── Assets.xcassets/                        # Цветовые наборы и графические ресурсы Xcode
```
