import UIKit

struct Order {
    let id: Int
    let customer: String
    let amount: Double // сумма заказа
    let isPaid: Bool
    let promoCode: String? // может отсутствовать
}

let orders: [Order] = [
    Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
    Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
    Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
    Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
    Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
]

// Получить массив сумм всех оплаченных заказов.
let paidOrders = orders.filter({order in !order.isPaid})

// Решение: исходная строка выше выбирает неоплаченные заказы.
let paidAmounts = orders.filter { order in
    order.isPaid
}.map { order in
    order.amount
}

// Найти общую сумму всех неоплаченных заказов (reduce).
let unpaidOrdersAmount = orders.filter({order in !order.isPaid}).reduce(0) {result, number in result + number.amount}

// Получить список уникальных имён клиентов, отсортированный по алфавиту.
let names = orders.map { order in
    order.customer
}
let uniqueNames = Set(names).sorted()

// Получить массив промокодов, исключив nil (compactMap).
let promoCodes = orders.compactMap { order in
    order.promoCode
}

// Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).
let ordersByCustomer: [String: [Order]] = Dictionary(grouping: orders) { order in
    order.customer
}

// Найти клиента с максимальной суммарной оплаченной суммой.
var paidTotals: [String: Double] = [:]

for order in orders {
    if order.isPaid {
        paidTotals[order.customer, default: 0] += order.amount
    }
}

let bestCustomer = paidTotals.max { first, second in
    first.value < second.value
}

if let customer = bestCustomer {
    print(customer.key, customer.value) // Анна 6600.0
}

/*
Point — структура с x, y типа Double:
mutating func move(byX:byY:);
вычисляемое свойство distanceToOrigin: Double;
соответствие Equatable, Hashable.
*/

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    mutating func move(byX: Double, byY: Double) {
        x += byX
        y += byY
    }

    var distanceToOrigin: Double {
        return (x * x + y * y).squareRoot()
    }
}

/*
Rectangle — структура с origin: Point, width, height:
вычисляемые свойства area, perimeter, center;
mutating func scale(by factor: Double);
func contains(_ point: Point) -> Bool;
init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.
*/

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin

        if width <= 0 {
            self.width = 1.0
        } else {
            self.width = width
        }

        if height <= 0 {
            self.height = 1.0
        } else {
            self.height = height
        }
    }

    var area: Double {
        return width * height
    }

    var perimeter: Double {
        return 2 * (width + height)
    }

    var center: Point {
        return Point(
            x: origin.x + width / 2,
            y: origin.y + height / 2
        )
    }

    mutating func scale(by factor: Double) {
        if factor > 0 {
            width *= factor
            height *= factor
        }
    }

    func contains(_ point: Point) -> Bool {
        return point.x >= origin.x &&
            point.x <= origin.x + width &&
            point.y >= origin.y &&
            point.y <= origin.y + height
    }
}

// Реализовать очередь с приоритетом кастомную
// Чем больше число приоритета, тем раньше извлекается элемент.
// При одинаковом приоритете сохраняется порядок добавления.

struct QueueItem {
    let value: String
    let priority: Int
}

struct PriorityQueue {
    private var items: [QueueItem] = []

    var isEmpty: Bool {
        return items.isEmpty
    }

    mutating func enqueue(_ value: String, priority: Int) {
        let item = QueueItem(value: value, priority: priority)
        items.append(item)
    }

    mutating func dequeue() -> String? {
        if items.isEmpty {
            return nil
        }

        var bestIndex = 0

        for index in items.indices {
            if items[index].priority > items[bestIndex].priority {
                bestIndex = index
            }
        }

        return items.remove(at: bestIndex).value
    }
}
