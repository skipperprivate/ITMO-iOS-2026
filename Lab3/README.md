# Lab3

**Петрушин Александр, К4141**

Приложение для iOS с двумя экранами, реализованное с использованием архитектуры MVVM (Model–View–ViewModel).

- `Model/RandomNumberModel.swift`: хранит текущее число и генерирует случайное значение в диапазоне от 1 до 300.
- `ViewModel/RandomNumberViewModel.swift`: управляет состоянием числа, используя `ObservableObject` и `@Published`, и вызывает методы модели.
- `View/FirstView.swift`: первый экран с отображением случайного числа, кнопкой генерации и переходом на второй экран.
- `View/SecondView.swift`: второй экран приложения.
- `View/ContentView.swift`: корневой интерфейс с `NavigationStack`.
- `App/lab3_mvvmApp.swift`: точка входа в приложение.

**Архитектура:** Model отвечает за данные и генерацию числа, ViewModel управляет состоянием, View отображает интерфейс, App запускает приложение.

**Запуск:** открыть `Разработка_ЛР_3/lab3_mvvm.xcodeproj` в Xcode, выбрать схему `lab3_mvvm` и симулятор iPhone, затем нажать Run.
