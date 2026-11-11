struct Order {
    let id: Int
    let customer: String
    let amount: Double
    let isPaid: Bool
    let promoCode: String?
}

let orders: [Order] = [
    Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
    Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
    Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
    Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
    Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
]

let paidAmounts = orders.filter { $0.isPaid }.map { $0.amount }

let unpaidTotal = orders.reduce(0.0) { $0 + ($1.isPaid ? 0 : $1.amount) }

let uniqueNames = Array(Set(orders.map { $0.customer })).sorted()

let promoCodes = orders.compactMap { $0.promoCode }

let ordersByCustomer = Dictionary(grouping: orders, by: { $0.customer })

let paidTotals = Dictionary(grouping: orders.filter { $0.isPaid }, by: { $0.customer })
    .mapValues { $0.reduce(0.0) { $0 + $1.amount } }

let topClient = paidTotals.max { $0.value < $1.value }
print(topClient?.key ?? "-", topClient?.value ?? 0)

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    mutating func move(byX dx: Double, byY dy: Double) {
        x += dx
        y += dy
    }

    var distanceToOrigin: Double {
        (x * x + y * y).squareRoot()
    }
}

struct Rectangle {
    private(set) var origin: Point
    private(set) var width: Double
    private(set) var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
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
        guard factor > 0 else { return }
        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        point.x >= origin.x && point.x <= origin.x + width &&
        point.y >= origin.y && point.y <= origin.y + height
    }
}

struct PriorityQueue<T> {
    private var items: [(value: T, priority: Int)] = []

    var isEmpty: Bool { items.isEmpty }

    mutating func enqueue(_ value: T, priority: Int) {
        items.append((value, priority))
    }

    mutating func dequeue() -> T? {
        guard let top = items.map(\.priority).max(),
              let index = items.firstIndex(where: { $0.priority == top })
        else { return nil }
        return items.remove(at: index).value
    }
}

var queue = PriorityQueue<String>()
queue.enqueue("low", priority: 1)
queue.enqueue("high", priority: 10)
queue.enqueue("high2", priority: 10)

print(queue.dequeue())
print(queue.dequeue())
print(queue.dequeue())
print(queue.dequeue())