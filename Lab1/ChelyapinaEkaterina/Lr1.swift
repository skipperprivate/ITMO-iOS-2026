// lr1
// task1
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

print("task 1")  
// Получить массив сумм всех оплаченных заказов.
let paidAmounts = orders
    .filter {$0.isPaid}
    .map {$0.amount}

print(paidAmounts)

// Найти общую сумму всех неоплаченных заказов (reduce).
let unpaidTotal = orders
    .filter { !$0.isPaid }
    .reduce(0.0) { $0 + $1.amount }

print(unpaidTotal)

// Получить список уникальных имён клиентов, отсортированный по алфавиту.
let uniqueCustomers = Set(orders.map { $0.customer })
    .sorted()

print(uniqueCustomers) 

// Получить массив промокодов, исключив nil (compactMap).
let promoCodes = orders.compactMap { $0.promoCode }

print(promoCodes)

// Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).
let ordersByCustomer = Dictionary(grouping: orders, by: { $0.customer })

// Найти клиента с максимальной суммарной оплаченной суммой.
let topCustomer = Dictionary(grouping: orders.filter { $0.isPaid }, by: { $0.customer })
    .mapValues { $0.reduce(0.0) { $0 + $1.amount } }
    .max { $0.value < $1.value }

print(topCustomer?.key ?? "-")

// task2
/* Point — структура с x, y типа Double:
mutating func move(byX:byY:);
вычисляемое свойство distanceToOrigin: Double;
соответствие Equatable, Hashable. */
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

/* Rectangle — структура с origin: Point, width, height:
вычисляемые свойства area, perimeter, center;
mutating func scale(by factor: Double);
func contains(_ point: Point) -> Bool;
init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0. */
struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width  = width  > 0 ? width  : 1.0
        self.height = height > 0 ? height : 1.0
    }

    var area: Double {
        width * height
    }

    var perimeter: Double {
        2 * (width + height)
    }

    var center: Point {
        Point(x: origin.x + width / 2,
              y: origin.y + height / 2)
    }

    mutating func scale(by factor: Double) {
        width  *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        point.x >= origin.x && point.x <= origin.x + width &&
        point.y >= origin.y && point.y <= origin.y + height
    }
}

print("\ntask 2")  
var p = Point(x: 3, y: 4)
print(p.distanceToOrigin)          
p.move(byX: 1, byY: -1)
print(p)                          

var r = Rectangle(origin: Point(x: 0, y: 0), width: 4, height: 6)
print(r.area)                      
print(r.perimeter)           
print(r.center)
print(r.contains(Point(x: 2, y: 3))) 
r.scale(by: 2)
print(r.width, r.height)

let bad = Rectangle(origin: Point(x: 0, y: 0), width: -1, height: 0)
print(bad.width, bad.height) 

// task3
// Реализовать очередь с приоритетом кастомную
struct PriorityQueue<Element> {
    private var elements: [(value: Element, priority: Int)] = []

    var isEmpty: Bool {
        elements.isEmpty
    }

    var count: Int {
        elements.count
    }

    mutating func enqueue(_ value: Element, priority: Int) {
        elements.append((value, priority))
        elements.sort { $0.priority > $1.priority }
    }

    mutating func dequeue() -> Element? {
        guard !elements.isEmpty else { return nil }
        return elements.removeFirst().value
    }

    func peek() -> Element? {
        elements.first?.value
    }
}

print("\ntask 3")  
var queue = PriorityQueue<String>()
queue.enqueue("Аня", priority: 2)
queue.enqueue("Боря", priority: 5)
queue.enqueue("Вика", priority: 1)
print(queue.peek() ?? "-")         
print(queue.dequeue() ?? "-")      
print(queue.dequeue() ?? "-")      
print(queue.dequeue() ?? "-")     
print(queue.isEmpty)  
