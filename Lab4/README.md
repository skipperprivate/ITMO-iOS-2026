# Lab4 — Генератор случайных чисел

iOS-приложение на SwiftUI с использованием паттерна MVVM и персистентностью данных через CoreData и UserDefaults.

## Структура проекта

```
Lab1/
├── Lab1App.swift          # Точка входа, настройка PersistenceController
├── Models/
│   └── GeneratedNumber.swift   # Модель генерации случайного числа
├── ViewModels/
│   ├── GeneratorViewModel.swift # ViewModel первого экрана
│   └── SecondViewModel.swift    # ViewModel экрана истории
├── Views/
│   ├── FirstView.swift          # Первый экран — генерация числа
│   └── SecondVIew.swift         # Второй экран — история генераций
└── Data/
    ├── PersistenceController.swift  # CoreData-контейнер
    ├── NumberRecord.swift           # CoreData-модель
    └── UserDefualts.swift           # Сервис для UserDefaults
```

## Функциональность

### Первый экран (FirstView)

- Отображение текущего сгенерированного числа
- Кнопка генерации нового случайного числа
- Переход на экран истории через `NavigationLink`
- Автоматическая загрузка последнего числа из UserDefaults при запуске
- Сохранение результата в CoreData и UserDefaults при каждом нажатии

### Второй экран (SecondView)

- Отображение списка всех сгенерированных чисел с временем
- Сортировка по убыванию даты (новые сверху)
- Кнопка очистки всей истории (иконка корзины)
- Пустое состояние — сообщение "История пуста"

## Архитектура

### ViewModel

**`GenerateNumberViewModel`** — управляет логикой генерации:
- Инициализация с загрузкой последнего числа из UserDefaults
- Метод `generateButtonTapped()` генерирует число, сохраняет в UserDefaults и CoreData
- Через `@Published` обновляет UI

**`SecondViewModel`** — управляет историей:
- Метод `load()` загружает записи из CoreData, сортирует по дате
- Метод `deleteAll()` удаляет все записи через `NSBatchDeleteRequest`

### Data Layer

**`PersistenceController`** — для работы с CoreData:
- Создаёт `NSPersistentContainer`
- Настраивает автоматическое слияние изменений
- Предоставляет метод `save()`

**`UserDefaultsService`** — обёртка над UserDefaults:
- Хранит последнее сгенерированное число
- Синхронизированный getter/setter для ключа `lastRandomNumber`
