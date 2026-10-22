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

//1) Получить массив сумм всех оплаченных заказов.

// более развёрнутая версия (для понимания)
//let paidOrders = orders.filter{order in return order.isPaid == true}
//let paidOrdersAmounts = paidOrders.map{paidOrder in return paidOrder.amount}

let paidOrders = orders.filter { $0.isPaid }
let paidOrdersAmounts = paidOrders.map { $0.amount }  // преобразует каждый элемент  
print("\nМассив сумм всех оплаченных заказов: \(paidOrdersAmounts)")


//2) Найти общую сумму всех неоплаченных заказов (reduce).

// по смыслу: 
//.reduce(0) { result, amount in
//    result + amount
//}

let totalAmount = orders
    .filter { !$0.isPaid }
    .map { $0.amount }
    .reduce(0, +)
print("\nОбщая сумма неоплаченных заказов: \(totalAmount)")


//3) Получить список уникальных имён клиентов, отсортированный по алфавиту.
let names = orders.map { $0.customer } // список имён
let sortedNames = Set(names).sorted() // sorted() не меняет исходную коллекцию
print("\nСписок уникальных имён клиентов, отсортированный по алфавиту: \(sortedNames)")


//4) Получить массив промокодов, исключив nil (compactMap).
let noNilPromo = orders.compactMap { $0.promoCode }
print("\nМассив промокодов: \(noNilPromo)")


//5) Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:))
let groupedOrders = Dictionary(
    grouping: orders,
    by: { $0.customer }
)
print("\n\(groupedOrders)")


//6) Найти клиента с максимальной суммарной оплаченной суммой
let paidTotals = groupedOrders.mapValues { // чтобы преобразовать значения словаря
    $0.filter { $0.isPaid }
    .map { $0.amount }
    .reduce(0, +)
}

// через if для print (словарь может быть пустым)
if let maxAmountClient = paidTotals.max(by: { $0.value < $1.value }) {
    print(
        "\nКлиент с максимальной суммарной оплаченной суммой: "
        + "\(maxAmountClient.key), \(maxAmountClient.value)"
    )
}
