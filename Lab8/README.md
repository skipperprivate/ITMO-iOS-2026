# Лабораторная работа №8 — SwiftLint

Ветка: `lab8`. Swift-исходники приложения и тестов не изменялись. Найденные нарушения зафиксированы для отдельного исправления.

## Подключение

- Пакет: [SimplyDanny/SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins). Это бинарные плагины из официального проекта SwiftLint.
- Версия закреплена точно: **0.65.1**; ревизия `ef7d692fc6706e8f5628e26bcafaefa445c58a97`.
- `SwiftLintBuildToolPlugin` добавлен в зависимости трёх таргетов: `MenuPlanner`, `MenuPlannerTests`, `MenuPlannerUITests`.
- Общие правила: [`Project/MenuPlanner/.swiftlint.yml`](../Project/MenuPlanner/.swiftlint.yml). Проверяются все три каталога исходников; стандартные правила не отключены, baseline не используется.
- Разрешённая версия сохранена в `MenuPlanner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

[Официальная инструкция подключения к Xcode](https://github.com/realm/SwiftLint#xcode-projects): при первом запуске плагин нужно включить через **Trust & Enable** в Xcode. Проверка запускается при сборке соответствующего таргета. Homebrew для сборки не требуется.

## Проверка

Проверено 19 ноября 2026: SwiftLint 0.65.1, Xcode 26.6.

Отдельный запуск SwiftLint обработал **67 Swift-файлов** и обнаружил **137 нарушений: 24 ошибки и 113 предупреждений**. Код возврата — `2`, поскольку найдены ошибки.

Плагин включён и проверен через `xcodebuild build-for-testing`: SwiftLint запустился для всех трёх таргетов. Сборка остановилась на 24 существующих ошибках lint, как и отдельный запуск проверки. Автоматическое исправление (`--fix`) не запускалось; исходники и тесты не редактировались.

Загрузка зависимости проверена через:

```sh
xcodebuild -resolvePackageDependencies \
  -project Project/MenuPlanner/MenuPlanner.xcodeproj \
  -scheme MenuPlanner
```

Сборка с проверкой всех трёх таргетов:

```sh
xcodebuild build-for-testing \
  -project Project/MenuPlanner/MenuPlanner.xcodeproj \
  -scheme MenuPlanner \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Если SwiftLint установлен отдельно, из каталога `Project/MenuPlanner` можно выполнить:

```sh
swiftlint lint --config .swiftlint.yml --no-cache
```

## Сводка нарушений

| Правило | Всего | Ошибки | Предупреждения |
| --- | ---: | ---: | ---: |
| `line_length` | 31 | 0 | 31 |
| `trailing_whitespace` | 30 | 0 | 30 |
| `identifier_name` | 21 | 20 | 1 |
| `switch_case_alignment` | 8 | 0 | 8 |
| `statement_position` | 7 | 0 | 7 |
| `no_space_in_method_call` | 6 | 0 | 6 |
| `optional_data_string_conversion` | 5 | 0 | 5 |
| `static_over_final_class` | 4 | 0 | 4 |
| `trailing_newline` | 3 | 0 | 3 |
| `type_body_length` | 3 | 1 | 2 |
| `colon` | 2 | 0 | 2 |
| `cyclomatic_complexity` | 2 | 0 | 2 |
| `function_body_length` | 2 | 0 | 2 |
| `large_tuple` | 2 | 1 | 1 |
| `nesting` | 2 | 0 | 2 |
| `function_parameter_count` | 1 | 0 | 1 |
| `control_statement` | 1 | 0 | 1 |
| `multiple_closures_with_trailing_closure` | 1 | 0 | 1 |
| `force_try` | 1 | 1 | 0 |
| `for_where` | 1 | 0 | 1 |
| `comma` | 1 | 0 | 1 |
| `vertical_whitespace` | 1 | 0 | 1 |
| `force_cast` | 1 | 1 | 0 |
| `file_length` | 1 | 0 | 1 |

## Полный список для исправления

Номера строк соответствуют неизменённым исходникам на момент проверки. Чекбоксы оставлены пустыми: нарушения не исправлялись.

### [MenuPlanner/MenuPlannerApp.swift](../Project/MenuPlanner/MenuPlanner/MenuPlannerApp.swift)

- [ ] Строка 48 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 49 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/Enums/MeasurementUnit.swift](../Project/MenuPlanner/MenuPlanner/Models/Enums/MeasurementUnit.swift)

- [ ] Строка 17 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/Ingredient.swift](../Project/MenuPlanner/MenuPlanner/Models/Ingredient.swift)

- [ ] Строка 12 — `colon` (предупреждение): Colons should be next to the identifier when specifying a type and next to the key in dictionary literals

### [MenuPlanner/Models/MealPlanEntry.swift](../Project/MenuPlanner/MenuPlanner/Models/MealPlanEntry.swift)

- [ ] Строка 17 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/Recipe.swift](../Project/MenuPlanner/MenuPlanner/Models/Recipe.swift)

- [ ] Строка 21 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 22 — `colon` (предупреждение): Colons should be next to the identifier when specifying a type and next to the key in dictionary literals
- [ ] Строка 24 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/RecipeIngredient.swift](../Project/MenuPlanner/MenuPlanner/Models/RecipeIngredient.swift)

- [ ] Строка 16 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/ShoppingItem.swift](../Project/MenuPlanner/MenuPlanner/Models/ShoppingItem.swift)

- [ ] Строка 18 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/ShoppingList.swift](../Project/MenuPlanner/MenuPlanner/Models/ShoppingList.swift)

- [ ] Строка 14 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 17 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Models/VkusVillProduct.swift](../Project/MenuPlanner/MenuPlanner/Models/VkusVillProduct.swift)

- [ ] Строка 46 — `cyclomatic_complexity` (предупреждение): Function should have complexity 10 or less; currently complexity is 12

### [MenuPlanner/Screens/Onboarding/OnboardingViewModel.swift](../Project/MenuPlanner/MenuPlanner/Screens/Onboarding/OnboardingViewModel.swift)

- [ ] Строка 12 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 16 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Screens/Recipes/Components/RecipeFormatting.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/Components/RecipeFormatting.swift)

- [ ] Строка 6 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 8 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace
- [ ] Строка 9 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace
- [ ] Строка 10 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace
- [ ] Строка 11 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace
- [ ] Строка 13 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Screens/Recipes/RecipeCard/RecipeCardView.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeCard/RecipeCardView.swift)

- [ ] Строка 31 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 155 characters
- [ ] Строка 63 — `trailing_newline` (предупреждение): Files should have a single trailing newline

### [MenuPlanner/Screens/Recipes/RecipeDetail/RecipeDetailView.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeDetail/RecipeDetailView.swift)

- [ ] Строка 137 — `multiple_closures_with_trailing_closure` (предупреждение): Trailing closure syntax should not be used when passing more than one closure argument
- [ ] Строка 175 — `trailing_newline` (предупреждение): Files should have a single trailing newline

### [MenuPlanner/Screens/Recipes/RecipeDetail/RecipeDetailViewModel.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeDetail/RecipeDetailViewModel.swift)

- [ ] Строка 37 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Screens/Recipes/RecipeEditor/RecipeEditorView.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeEditor/RecipeEditorView.swift)

- [ ] Строка 5 — `type_body_length` (предупреждение): Struct body should span 250 lines or less excluding comments and whitespace: currently spans 254 lines
- [ ] Строка 39 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 123 characters
- [ ] Строка 45 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 141 characters
- [ ] Строка 48 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 137 characters
- [ ] Строка 65 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 132 characters
- [ ] Строка 83 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 146 characters
- [ ] Строка 91 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 121 characters

### [MenuPlanner/Screens/Recipes/RecipeEditor/RecipeEditorViewModel.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeEditor/RecipeEditorViewModel.swift)

- [ ] Строка 90 — `for_where` (предупреждение): \`where\` clauses are preferred over a single \`if\` inside a \`for\`
- [ ] Строка 133 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 135 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 139 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Screens/Recipes/RecipeEditor/RecipeIngredientDraft.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeEditor/RecipeIngredientDraft.swift)

- [ ] Строка 29 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlanner/Screens/Recipes/RecipeImport/RecipeImportMapper.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/RecipeImport/RecipeImportMapper.swift)

- [ ] Строка 27 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 121 characters
- [ ] Строка 33 — `cyclomatic_complexity` (предупреждение): Function should have complexity 10 or less; currently complexity is 11

### [MenuPlanner/Screens/Recipes/Recipes/RecipesView.swift](../Project/MenuPlanner/MenuPlanner/Screens/Recipes/Recipes/RecipesView.swift)

- [ ] Строка 167 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 123 characters
- [ ] Строка 171 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 125 characters
- [ ] Строка 232 — `force_try` (ошибка): Force tries should be avoided

### [MenuPlanner/Screens/Shopping/ShoppingView.swift](../Project/MenuPlanner/MenuPlanner/Screens/Shopping/ShoppingView.swift)

- [ ] Строка 4 — `type_body_length` (предупреждение): Struct body should span 250 lines or less excluding comments and whitespace: currently spans 257 lines
- [ ] Строка 191 — `function_body_length` (предупреждение): Function body should span 50 lines or less excluding comments and whitespace: currently spans 63 lines

### [MenuPlanner/Screens/Shopping/VkusVillCartViewModel.swift](../Project/MenuPlanner/MenuPlanner/Screens/Shopping/VkusVillCartViewModel.swift)

- [ ] Строка 106 — `control_statement` (предупреждение): \`if\`, \`for\`, \`guard\`, \`switch\`, \`while\`, and \`catch\` statements shouldn't unnecessarily wrap their conditionals or arguments in parentheses

### [MenuPlanner/Screens/WeekPlan/WeekPlanView.swift](../Project/MenuPlanner/MenuPlanner/Screens/WeekPlan/WeekPlanView.swift)

- [ ] Строка 191 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 129 characters
- [ ] Строка 198 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 123 characters

### [MenuPlanner/Screens/WeekPlan/WeekPlanViewModel.swift](../Project/MenuPlanner/MenuPlanner/Screens/WeekPlan/WeekPlanViewModel.swift)

- [ ] Строка 45 — `function_parameter_count` (предупреждение): Function should have 5 parameters or less: it currently has 6

### [MenuPlanner/Services/Networking/VkusVillCatalog.swift](../Project/MenuPlanner/MenuPlanner/Services/Networking/VkusVillCatalog.swift)

- [ ] Строка 6 — `identifier_name` (ошибка): Variable name 'q' should be between 3 and 40 characters long
- [ ] Строка 41 — `nesting` (предупреждение): Types should be nested at most 1 level deep
- [ ] Строка 50 — `identifier_name` (предупреждение): Variable name 'ok' should be between 3 and 40 characters long
- [ ] Строка 55 — `identifier_name` (ошибка): Variable name 'q' should be between 3 and 40 characters long
- [ ] Строка 66 — `identifier_name` (ошибка): Variable name 'q' should be between 3 and 40 characters long
- [ ] Строка 69 — `identifier_name` (ошибка): Variable name 'id_feature_filter' should only contain alphanumeric and other allowed characters
- [ ] Строка 70 — `identifier_name` (ошибка): Variable name 'id_cooking_time_filter' should only contain alphanumeric and other allowed characters
- [ ] Строка 71 — `identifier_name` (ошибка): Variable name 'id_cooking_method_filter' should only contain alphanumeric and other allowed characters
- [ ] Строка 72 — `identifier_name` (ошибка): Variable name 'id_complexity_filter' should only contain alphanumeric and other allowed characters
- [ ] Строка 73 — `identifier_name` (ошибка): Variable name 'id_category_filter' should only contain alphanumeric and other allowed characters
- [ ] Строка 74 — `identifier_name` (ошибка): Variable name 'id_exclude_allergens_filter' should only contain alphanumeric and other allowed characters
- [ ] Строка 78 — `nesting` (предупреждение): Types should be nested at most 1 level deep
- [ ] Строка 218 — `optional_data_string_conversion` (предупреждение): Prefer failable \`String(bytes:encoding:)\` initializer when converting \`Data\` to \`String\`

### [MenuPlanner/Services/Persistence/DataStore.swift](../Project/MenuPlanner/MenuPlanner/Services/Persistence/DataStore.swift)

- [ ] Строка 7 — `trailing_newline` (предупреждение): Files should have a single trailing newline

### [MenuPlanner/Services/ShoppingListBuilder.swift](../Project/MenuPlanner/MenuPlanner/Services/ShoppingListBuilder.swift)

- [ ] Строка 11 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 14 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 19 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 21 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 24 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 26 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 27 — `comma` (предупреждение): There should be no space before and one after any comma
- [ ] Строка 30 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 41 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 46 — `vertical_whitespace` (предупреждение): Limit vertical whitespace to a single empty line; currently 2
- [ ] Строка 49 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 52 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace

### [MenuPlanner/Services/UnitConverter.swift](../Project/MenuPlanner/MenuPlanner/Services/UnitConverter.swift)

- [ ] Строка 10 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace
- [ ] Строка 13 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace
- [ ] Строка 14 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace
- [ ] Строка 15 — `switch_case_alignment` (предупреждение): Case statements should vertically aligned with their closing brace

### [MenuPlanner/Services/UserSettings.swift](../Project/MenuPlanner/MenuPlanner/Services/UserSettings.swift)

- [ ] Строка 23 — `no_space_in_method_call` (предупреждение): Don't add a space between the method name and the parentheses
- [ ] Строка 29 — `no_space_in_method_call` (предупреждение): Don't add a space between the method name and the parentheses
- [ ] Строка 36 — `no_space_in_method_call` (предупреждение): Don't add a space between the method name and the parentheses
- [ ] Строка 38 — `no_space_in_method_call` (предупреждение): Don't add a space between the method name and the parentheses
- [ ] Строка 46 — `no_space_in_method_call` (предупреждение): Don't add a space between the method name and the parentheses
- [ ] Строка 47 — `no_space_in_method_call` (предупреждение): Don't add a space between the method name and the parentheses

### [MenuPlanner/Testing/UITestNetwork.swift](../Project/MenuPlanner/MenuPlanner/Testing/UITestNetwork.swift)

- [ ] Строка 18 — `static_over_final_class` (предупреждение): Prefer \`static\` over \`class\` in a final class
- [ ] Строка 19 — `static_over_final_class` (предупреждение): Prefer \`static\` over \`class\` in a final class
- [ ] Строка 21 — `function_body_length` (предупреждение): Function body should span 50 lines or less excluding comments and whitespace: currently spans 55 lines
- [ ] Строка 73 — `optional_data_string_conversion` (предупреждение): Prefer failable \`String(bytes:encoding:)\` initializer when converting \`Data\` to \`String\`

### [MenuPlanner/Theme/AppColors.swift](../Project/MenuPlanner/MenuPlanner/Theme/AppColors.swift)

- [ ] Строка 19 — `trailing_whitespace` (предупреждение): Lines should not have trailing whitespace

### [MenuPlannerTests/CatalogTestSupport.swift](../Project/MenuPlanner/MenuPlannerTests/CatalogTestSupport.swift)

- [ ] Строка 29 — `static_over_final_class` (предупреждение): Prefer \`static\` over \`class\` in a final class
- [ ] Строка 30 — `static_over_final_class` (предупреждение): Prefer \`static\` over \`class\` in a final class
- [ ] Строка 95 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 129 characters
- [ ] Строка 95 — `optional_data_string_conversion` (предупреждение): Prefer failable \`String(bytes:encoding:)\` initializer when converting \`Data\` to \`String\`
- [ ] Строка 100 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 130 characters
- [ ] Строка 100 — `optional_data_string_conversion` (предупреждение): Prefer failable \`String(bytes:encoding:)\` initializer when converting \`Data\` to \`String\`
- [ ] Строка 120 — `force_cast` (ошибка): Force casts should be avoided

### [MenuPlannerTests/PersistenceAndFormattingTests.swift](../Project/MenuPlanner/MenuPlannerTests/PersistenceAndFormattingTests.swift)

- [ ] Строка 24 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 127 characters
- [ ] Строка 135 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 121 characters

### [MenuPlannerTests/PersistenceFailureTests.swift](../Project/MenuPlanner/MenuPlannerTests/PersistenceFailureTests.swift)

- [ ] Строка 28 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 122 characters
- [ ] Строка 51 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 129 characters
- [ ] Строка 74 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 121 characters
- [ ] Строка 116 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 125 characters
- [ ] Строка 153 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 125 characters

### [MenuPlannerTests/RecipeEditorAdvancedTests.swift](../Project/MenuPlanner/MenuPlannerTests/RecipeEditorAdvancedTests.swift)

- [ ] Строка 61 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 142 characters
- [ ] Строка 126 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 159 characters
- [ ] Строка 133 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 159 characters
- [ ] Строка 143 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 121 characters

### [MenuPlannerTests/RecipeImportMapperTests.swift](../Project/MenuPlanner/MenuPlannerTests/RecipeImportMapperTests.swift)

- [ ] Строка 45 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 122 characters
- [ ] Строка 55 — `large_tuple` (предупреждение): Tuples should have at most 2 members

### [MenuPlannerTests/RecipesViewModelTests.swift](../Project/MenuPlanner/MenuPlannerTests/RecipesViewModelTests.swift)

- [ ] Строка 44 — `identifier_name` (ошибка): Variable name 'a' should be between 3 and 40 characters long
- [ ] Строка 45 — `identifier_name` (ошибка): Variable name 'b' should be between 3 and 40 characters long
- [ ] Строка 46 — `identifier_name` (ошибка): Variable name 'c' should be between 3 and 40 characters long

### [MenuPlannerTests/ShoppingListBuilderTests.swift](../Project/MenuPlanner/MenuPlannerTests/ShoppingListBuilderTests.swift)

- [ ] Строка 62 — `large_tuple` (ошибка): Tuples should have at most 2 members

### [MenuPlannerTests/VkusVillCartViewModelTests.swift](../Project/MenuPlanner/MenuPlannerTests/VkusVillCartViewModelTests.swift)

- [ ] Строка 7 — `identifier_name` (ошибка): Variable name 'a' should be between 3 and 40 characters long
- [ ] Строка 8 — `identifier_name` (ошибка): Variable name 'b' should be between 3 and 40 characters long
- [ ] Строка 22 — `identifier_name` (ошибка): Variable name 'a' should be between 3 and 40 characters long
- [ ] Строка 23 — `identifier_name` (ошибка): Variable name 'b' should be between 3 and 40 characters long
- [ ] Строка 91 — `identifier_name` (ошибка): Variable name 'a' should be between 3 and 40 characters long
- [ ] Строка 92 — `identifier_name` (ошибка): Variable name 'b' should be between 3 and 40 characters long
- [ ] Строка 115 — `identifier_name` (ошибка): Variable name 'a' should be between 3 and 40 characters long
- [ ] Строка 116 — `identifier_name` (ошибка): Variable name 'b' should be between 3 and 40 characters long

### [MenuPlannerTests/VkusVillCatalogTests.swift](../Project/MenuPlanner/MenuPlannerTests/VkusVillCatalogTests.swift)

- [ ] Строка 65 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration
- [ ] Строка 88 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration
- [ ] Строка 94 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration
- [ ] Строка 101 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration
- [ ] Строка 114 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration
- [ ] Строка 142 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration
- [ ] Строка 164 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 132 characters
- [ ] Строка 164 — `statement_position` (предупреждение): Else and catch should be on the same line, one space after the previous declaration

### [MenuPlannerTests/VkusVillProductTests.swift](../Project/MenuPlanner/MenuPlannerTests/VkusVillProductTests.swift)

- [ ] Строка 10 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 126 characters

### [MenuPlannerTests/VkusVillSearchViewModelTests.swift](../Project/MenuPlanner/MenuPlannerTests/VkusVillSearchViewModelTests.swift)

- [ ] Строка 40 — `optional_data_string_conversion` (предупреждение): Prefer failable \`String(bytes:encoding:)\` initializer when converting \`Data\` to \`String\`
- [ ] Строка 41 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 133 characters

### [MenuPlannerTests/WeekPlanTests.swift](../Project/MenuPlanner/MenuPlannerTests/WeekPlanTests.swift)

- [ ] Строка 26 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 123 characters

### [MenuPlannerUITests/MenuPlannerUITests.swift](../Project/MenuPlanner/MenuPlannerUITests/MenuPlannerUITests.swift)

- [ ] Строка 4 — `type_body_length` (ошибка): Class body should span 350 lines or less excluding comments and whitespace: currently spans 369 lines
- [ ] Строка 314 — `line_length` (предупреждение): Line should be 120 characters or less; currently it has 127 characters
- [ ] Строка 405 — `file_length` (предупреждение): File should contain 400 lines or less: currently contains 405

## Что изменено

- `.swiftlint.yml` — добавлена конфигурация проверки.
- `MenuPlanner.xcodeproj/project.pbxproj` — добавлен пакет и плагин для трёх таргетов.
- `MenuPlanner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` — зафиксированы версия и ревизия пакета.
- `Lab8/README.md` — описание подключения и полный список нарушений.
