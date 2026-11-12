

import Foundation

struct Order {
    let id: Int
    let customer: String
    let amount: Double
    let isPaid: Bool
    let promoCode: String?
}

let orders: [Order] = [
    Order(id: 1, customer: "Анна", amount: 1_200, isPaid: true, promoCode: "SALE10"),
    Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
    Order(id: 3, customer: "Анна", amount: 5_400, isPaid: true, promoCode: nil),
    Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
    Order(id: 5, customer: "Иван", amount: 2_100, isPaid: false, promoCode: "SALE10")
]

// Часть 1. Работа с коллекциями.
let paidAmounts = orders.filter(\.isPaid).map(\.amount)
let unpaidTotal = orders.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
let uniqueCustomers = Array(Set(orders.map(\.customer))).sorted()
let promoCodes = orders.compactMap(\.promoCode)
let ordersByCustomer = Dictionary(grouping: orders, by: \.customer)

let paidTotalByCustomer = Dictionary(grouping: orders.filter(\.isPaid), by: \.customer)
    .mapValues { $0.reduce(0) { $0 + $1.amount } }
let maximumPaidTotal = paidTotalByCustomer.values.max()
let topPaidCustomers = paidTotalByCustomer
    .filter { $0.value == maximumPaidTotal }
    .map(\.key)
    .sorted()

// Часть 2. Геометрические структуры.
struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    var distanceToOrigin: Double {
        (x * x + y * y).squareRoot()
    }

    mutating func move(byX xOffset: Double, byY yOffset: Double) {
        x += xOffset
        y += yOffset
    }
}

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    var area: Double {
        width * height
    }

    var perimeter: Double {
        2 * (width + height)
    }

    var center: Point {
        Point(x: origin.x + width / 2, y: origin.y + height / 2)
    }

    init(origin: Point, width: Double, height: Double) {
        guard width > 0, height > 0 else {
            self.origin = origin
            self.width = 1
            self.height = 1
            return
        }

        self.origin = origin
        self.width = width
        self.height = height
    }

    mutating func scale(by factor: Double) {
        guard factor >= 0 else { return }
        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        let containsX = (origin.x...(origin.x + width)).contains(point.x)
        let containsY = (origin.y...(origin.y + height)).contains(point.y)
        return containsX && containsY
    }
}

// Часть 3. Обобщённая очередь с приоритетом.
struct PriorityQueue<T: Comparable> {
    private var items: [T] = []

    mutating func enqueue(_ element: T) {
        items.append(element)
    }

    mutating func dequeue() -> T? {
        guard let maximum = items.max(), let index = items.firstIndex(of: maximum) else {
            return nil
        }

        return items.remove(at: index)
    }
}

var priorityQueue = PriorityQueue<Int>()
priorityQueue.enqueue(4)
priorityQueue.enqueue(5)
priorityQueue.enqueue(1)
priorityQueue.enqueue(10)
priorityQueue.enqueue(3)

let firstHighestPriority = priorityQueue.dequeue()
let secondHighestPriority = priorityQueue.dequeue()

print("Оплаченные суммы: \(paidAmounts)")
print("Сумма неоплаченных заказов: \(unpaidTotal)")
print("Клиенты: \(uniqueCustomers)")
print("Промокоды: \(promoCodes)")
print("Заказы по клиентам: \(ordersByCustomer)")
print("Клиенты с максимальной оплаченной суммой: \(topPaidCustomers)")
print("Первый максимальный приоритет: \(firstHighestPriority ?? 0)")
print("Второй максимальный приоритет: \(secondHighestPriority ?? 0)")
