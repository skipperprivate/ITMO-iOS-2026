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

let unpaidTotal = orders
    .filter { !$0.isPaid }
    .reduce(0) { partialSum, order in partialSum + order.amount }

let uniqueCustomers = Set(orders.map { $0.customer }).sorted()

let promoCodes = orders.compactMap { $0.promoCode }

let groupedByCustomer = Dictionary(grouping: orders, by: { $0.customer })

let paidTotalsByCustomer = Dictionary(grouping: orders.filter { $0.isPaid }, by: { $0.customer })
    .mapValues { $0.reduce(0) { $0 + $1.amount } }

let topCustomer = paidTotalsByCustomer.max { $0.value < $1.value }

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
    var origin: Point
    var width: Double
    var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
    }

    var area: Double { width * height }
    var perimeter: Double { 2 * (width + height) }

    var center: Point {
        Point(x: origin.x + width / 2, y: origin.y + height / 2)
    }

    mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        point.x >= origin.x && point.x <= origin.x + width &&
        point.y >= origin.y && point.y <= origin.y + height
    }
}

struct PriorityQueue<Element> {
    private var elements: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(sortedBy areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var isEmpty: Bool { elements.isEmpty }
    var count: Int { elements.count }
    var peek: Element? { elements.first }

    mutating func enqueue(_ element: Element) {
        elements = (elements + [element]).sorted(by: areInIncreasingOrder)
    }

    mutating func dequeue() -> Element? {
        guard !elements.isEmpty else { return nil }
        return elements.removeFirst()
    }
}

var pq = PriorityQueue<Order>(sortedBy: { $0.amount > $1.amount })
orders.forEach { pq.enqueue($0) }

while let next = pq.dequeue() {
    print(next.customer, next.amount)
}
