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

let paidOrders = orders.filter { $0.isPaid }.map { $0.amount }
print(paidOrders)

// Найти общую сумму всех неоплаченных заказов (reduce).

let priceNotPaidOrders = orders.reduce(0) { sumOfUnpaidOrders, order in
    if !order.isPaid {
        return sumOfUnpaidOrders + order.amount
    }
    return sumOfUnpaidOrders
}

print(priceNotPaidOrders)

// Получить список уникальных имён клиентов, отсортированный по алфавиту.

let uniqueNames = Set(orders.map { $0.customer }).sorted()
print(uniqueNames)

// Получить массив промокодов, исключив nil (compactMap).

let promoCodes = orders.compactMap { $0.promoCode }
print(promoCodes)

// Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).

let ordersByCustomer: [String: [Order]] = Dictionary(grouping: orders, by: { $0.customer })
print(ordersByCustomer)

// Найти клиента с максимальной суммарной оплаченной суммой.

let topCustomer = orders
    .filter { $0.isPaid }
    .reduce(into: [String: Double]()) { totals, order in
        totals[order.customer, default: 0] += order.amount
    }
    .max { $0.value < $1.value }

if let customer = topCustomer {
    print("Клиент: \(customer.key), оплачено: \(customer.value)")
}
