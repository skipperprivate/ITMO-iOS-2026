# Lab5 — Генератор случайных чисел с многопоточностью

iOS-приложение на SwiftUI с паттерном MVVM, персистентностью данных и многопоточной обработкой CoreData.


## Структура проекта

```
Lab1/
├── Lab1App.swift                # Точка входа, настройка PersistenceController
├── Models/
│   └── GeneratedNumber.swift    # Модель генерации случайного числа
├── ViewModels/
│   ├── GeneratorViewModel.swift # ViewModel первого экрана (@MainActor)
│   └── SecondViewModel.swift    # ViewModel экрана истории (@MainActor)
├── Views/
│   ├── FirstView.swift          # Первый экран — генерация числа
│   └── SecondVIew.swift         # Второй экран — история генераций
└── Data/
    ├── PersistenceController.swift  # CoreData-контейнер + фоновые контексты
    ├── NumberRecord.swift           # CoreData-модель
    └── UserDefualts.swift           # Сервис для UserDefaults
```

## Функциональность

### Первый экран (FirstView)

- Отображение текущего сгенерированного числа (1–100)
- Кнопка генерации нового случайного числа
- Переход на экран истории через `NavigationLink`
- Автоматическая загрузка последнего числа из UserDefaults при запуске
- Асинхронное сохранение в CoreData без блокировки UI

### Второй экран (SecondView)

- Отображение списка всех сгенерированных чисел с временем
- Состояние загрузки (`isLoading`) во время запроса к базе
- Сортировка по убыванию даты (новые сверху)
- Кнопка очистки всей истории
- Пустое состояние — сообщение "История пуста"

## Архитектура

### Многопоточность

Многопоточность реализована в **двух местах**:

#### 1. PersistenceController — фоновые контексты CoreData

Все операции с данными выполняются в фоновых контекстах через `container.newBackgroundContext()` и `context.perform`:

```swift
func save(value: Int) async {
    let context = container.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    await context.perform {
        let record = NumberRecord(context: context)
        record.id = UUID()
        record.value = Int64(value)
        record.date = Date()
        try context.save()
    }
}
```

#### 2. ViewModels — async/await + @MainActor

ViewModel-классы помечены `@MainActor`, а асинхронные вызовы выполняются через `Task`:

```swift
@MainActor
final class GenerateNumberViewModel: ObservableObject {
    func generateButtonTapped() {
        model.generate()
        userDefaults.lastRandomNumber = newValue
        
        Task {
            await persistence.save(value: newValue)
        }
    }
}

@MainActor
class SecondViewModel: ObservableObject {
    func load() {
        Task {
            isLoading = true
            let fetched = await persistence.fetch()
            self.records = fetched
            isLoading = false
        }
    }
}
```

### Data Layer

**`PersistenceController`** — синглтон с асинхронными методами:
- `save(value:)` — асинхронное сохранение в фоновом контексте
- `fetch()` — асинхронная загрузка с возвратом `ObservableObject`-обёрток
- `deleteAll()` — асинхронное удаление через `NSBatchDeleteRequest`

**`UserDefaultsService`** — синхронная обёртка над UserDefaults (не требует многопоточности).

## Ключевые отличия от Lab4

| Компонент | Lab4 | Lab5 |
|-----------|------|------|
| `PersistenceController` | синхронные методы, `viewContext` | `async`, фоновые контексты `newBackgroundContext()` |
| `GeneratorViewModel` | синхронный вызов `save()` | `Task { await save() }` |
| `SecondViewModel` | синхронный `fetch()` | `Task { await fetch() }`, добавлен `isLoading` |
| `@MainActor` | отсутствует | добавлен на оба ViewModel |
