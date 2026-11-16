import Foundation

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


//Получить массив сумм всех оплаченных заказов.
//
let paidOrders = orders.filter(\.isPaid).map(\.amount)
//Найти общую сумму всех неоплаченных заказов (reduce).
//
let sumReduceOrders  = orders.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
//Получить список уникальных имён клиентов, отсортированный по алфавиту.
//
let customers = Set(orders.map(\.customer)).sorted()
//Получить массив промокодов, исключив nil (compactMap).
//
let promocodes = Set(orders.compactMap(\.promoCode))
//Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).
//
let groupedOrders = Dictionary<String, [Order]>(grouping: orders, by:  \.customer)
//Найти клиента с максимальной суммарной оплаченной суммой.
let totals = orders.reduce(into: [String: Double]()) { result, order in
    if order.isPaid {
        result[order.customer, default: 0] += order.amount
    }
}
let maxClient = totals.max(by: $1)
