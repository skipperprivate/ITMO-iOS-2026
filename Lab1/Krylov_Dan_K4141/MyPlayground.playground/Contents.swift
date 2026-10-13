//Задание 1
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

print("-----1 TASK-----")

//Получить массив сумм всех оплаченных заказов.
//
let paidAmount = orders.filter{ $0.isPaid }.map{ $0.amount }
print(paidAmount)
//Найти общую сумму всех неоплаченных заказов (reduce).
//
let unpaidSum = orders.filter{ !$0.isPaid}.map{ $0.amount}.reduce(0) { $0 + $1 }
print(unpaidSum)
//Получить список уникальных имён клиентов, отсортированный по алфавиту.
//
let distinctUsersAsc =  Set(orders.map{$0.customer}).sorted()
print(distinctUsersAsc)
//Получить массив промокодов, исключив nil (compactMap).
//
let promoArray = orders.compactMap{ $0.promoCode }
print(promoArray)
//Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).
//
let ordersByUsers = Dictionary(grouping: orders, by: {$0.customer})
print(ordersByUsers)
//Найти клиента с максимальной суммарной оплаченной суммой.
let paidUsers = orders.filter{ $0.isPaid }
let paidUsersDict = Dictionary(grouping: paidUsers, by: {$0.customer})
let totalByCustomer = paidUsersDict.mapValues{ $0.reduce(0) {$0+$1.amount}}
let topCustomer = totalByCustomer.max { $0.value < $1.value }
print(topCustomer)
// Задание 2
//  Point — структура с x, y типа Double:
//  mutating func move(byX:byY:);
//  вычисляемое свойство distanceToOrigin: Double;
//  соответствие Equatable, Hashable.

print("\n-----2 TASK-----")
struct Point: Equatable, Hashable {
    var x: Double
    var y: Double
    
    mutating func move (byX: Double, byY: Double){
        self.x += byX
        self.y += byY
    }
    
    var distanceToOrigin: Double {
        (x*x + y*y).squareRoot()
    }
}

//Тесты для Point
var p = Point(x: 1, y: 2)
p.move(byX: 2, byY: 2)
print(p)
print(p.distanceToOrigin)

let p1 = Point(x: 1, y: 2)
let p2 = Point(x: 1, y: 2)
print(p1 == p2)

//Rectangle — структура с origin: Point, width, height:
//
//вычисляемые свойства area, perimeter, center;
//
//mutating func scale(by factor: Double);
//
//func contains(_ point: Point) -> Bool;
//
//init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.
struct Rectangle{
    var origin: Point
    var width: Double
    var height: Double
    
    init (origin: Point, width: Double, height: Double){
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
    }
    
    var area: Double {width*height}

    var perimeter: Double {(width+height)*2}

    var center: Point {Point( x: origin.x + width/2, y: origin.y + height/2)}
    
    mutating func scale (by factor: Double){
        width *= factor
        height *= factor
    }
    
    func contains (_ point: Point) -> Bool {
        let insideX = point.x >= origin.x && point.x <= (origin.x + width)
        let insideY = point.y >= origin.y && point.y <= (origin.y + height)
        return insideX && insideY
    }
}

//Тест Rectangle
var r1 = Rectangle(origin: Point(x: 0, y: 0), width: -5, height: 10)
print(r1.width)
print(r1.area, r1.perimeter, r1.center)
r1.scale(by: 2)
print(r1.contains(p), p)
print(r1)

print("\n-----3 TASK-----")


//Приоритетная очередь

struct PriorityQueue<Element> {
    private var items: [(element: Element, priority: Int)] = []
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    var peek: Element? {
        items.first?.element
    }
    
    mutating func enqueue(_ element: Element, _ priority: Int) {
        items.append((element: element, priority: priority))
        items.sort { $0.priority > $1.priority }
    }
    
    mutating func dequeue() -> Element? {
        isEmpty ? nil : items.removeFirst().element
    }
}

var pQ = PriorityQueue<String>()
pQ.enqueue("Noob", 4)
print(pQ.peek)
pQ.enqueue("Pro", 10)
print(pQ.peek)



