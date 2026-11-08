// Часть 1

struct Order {
let id: Int
let customer: String
let amount: Double // сумма заказа
let isPaid: Bool
let promoCode: String? // может отсутствовать
}

let orders: [Order] = [
Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
Order(id: 1, customer: "Анна1", amount: 1200, isPaid: true, promoCode: "SALE10"),
Order(id: 3, customer: "Анна1", amount: 5400, isPaid: true, promoCode: nil),
Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
]


// Получить массив сумм всех оплаченных заказов.

print(orders.filter { $0.isPaid } .map { $0.amount })

// Найти общую сумму всех неоплаченных заказов (reduce).

print(orders.filter { !$0.isPaid } .reduce(0) { sum, order in sum + order.amount })

// Получить список уникальных имён клиентов, отсортированный по алфавиту.

print(Array(Set(orders .map { $0.customer })) .sorted())

// Получить массив промокодов, исключив nil (compactMap).

// До Swift 4.1 (stackoverflow)
// print(orders.flatMap { $0.promoCode })

print(orders.compactMap { $0.promoCode })

// Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).

print(Dictionary(grouping: orders, by: { $0.customer }))

// Найти клиента с максимальной суммарной оплаченной суммой.

let customersWithSumOrders = Dictionary(grouping: orders.filter { $0.isPaid }, by: { $0.customer })
.mapValues { orders in orders .reduce(0) { sum, order in sum + order.amount } }

let maxSum = customersWithSumOrders.values.max()

let bestCustomers = customersWithSumOrders .filter { $0.value == maxSum } .map { $0.key } .sorted()

print(bestCustomers)


// Часть 2
// Point — структура с x, y типа Double:
// mutating func move(byX:byY:);
// вычисляемое свойство distanceToOrigin: Double;
// соответствие Equatable, Hashable.
// Rectangle — структура с origin: Point, width, height:
// вычисляемые свойства area, perimeter, center;
// mutating func scale(by factor: Double);
// func contains(_ point: Point) -> Bool;
// init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.

import Foundation

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    var distanceToOrigin: Double {
        sqrt(x * x + y * y)
    }

    mutating func move(byX: Double, byY: Double) {
        self.x += byX
        self.y += byY
    }
}

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width <= 0 ? 1.0 : width
        self.height = height <= 0 ? 1.0 : height
    }

    var area: Double {
        width * height
    }

    var perimeter: Double {
        2 * (width + height)
    }
    
    var center: Point {
        Point(x: origin.x + width / 2, y: origin.y + height / 2)
    }

    mutating func scale(by factor: Double) {
        self.width *= factor
        self.height *= factor
    }

    func contains(_ point: Point) -> Bool {
        let isXInside = point.x >= origin.x && point.x <= (origin.x + width)
        let isYInside = point.y >= origin.y && point.y <= (origin.y + height)
        return isXInside && isYInside
    }
}


// Часть 3
// Реализовать очередь с приоритетом кастомную

struct Task {
    let name: String
    let priority: Int
}

struct PriorityQueue {

    private var items: [Task] = []

    mutating func enqueue(_ element: Task) {
        if let index = items.firstIndex(where: { element.priority > $0.priority }) {
            items.insert(element, at: index)
        } else {
            items.append(element)
        }
    }

    mutating func dequeue() -> Task? {
        items.isEmpty ? nil : items.removeFirst()
    }
}

var tasks = PriorityQueue()

tasks.enqueue(Task(name: "Исправить баг", priority: 4))
tasks.enqueue(Task(name: "Проверить MR", priority: 5))
tasks.enqueue(Task(name: "Минорный рефакторинг", priority: 1))
tasks.enqueue(Task(name: "Хотфикс", priority: 10))
tasks.enqueue(Task(name: "Задача в след релиз", priority: 3))

while let task = tasks.dequeue() {
    print(task.name)
}
