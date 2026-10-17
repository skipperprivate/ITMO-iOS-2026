# Задание 1

[`task1.swift`](./task1.swift)

```swift
struct Order {
    let id: Int
    let customer: String
    let amount: Double // сумма заказа
    let isPaid: Bool
    let promoCode: String? // может отсутствовать
}
```

```swift
let orders: [Order] = [
    Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
    Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
    Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
    Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
    Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
]
```

1. Получить массив сумм всех оплаченных заказов.

2. Найти общую сумму всех неоплаченных заказов (reduce).

3. Получить список уникальных имён клиентов, отсортированный по алфавиту.

4. Получить массив промокодов, исключив nil (compactMap).

5. Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).

6. Найти клиента с максимальной суммарной оплаченной суммой.

# Задание 2

[`task2.swift`](./task2.swift)

**Point — структура с x, y типа Double:**

**mutating func move(byX:byY:);**

1. вычисляемое свойство distanceToOrigin: Double;

2. соответствие Equatable, Hashable.

3. Rectangle — структура с origin: Point, width, height:

4. вычисляемые свойства area, perimeter, center;

5. mutating func scale(by factor: Double);

6. func contains(_ point: Point) -> Bool;

7. init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.

# Задание 3

[`task3.swift`](./task3.swift)

Реализовать очередь с приоритетом кастомную
