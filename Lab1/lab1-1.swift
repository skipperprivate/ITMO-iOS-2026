struct Order {
    let id: Int
    let customer: String
    let amount: Double
    let isPaid: Bool
    let promoCode: String?
}

func task1() {
    let orders: [Order] = [
        Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
        Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
        Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
        Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
        Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
    ]

    let paidAmounts = orders
        .filter { $0.isPaid }
        .map { $0.amount }

    let unpaidTotal = orders
        .filter { !$0.isPaid }
        .reduce(0) { $0 + $1.amount }

    let customers = Array(Set(orders.map { $0.customer })).sorted()

    let promoCodes = orders.compactMap { $0.promoCode }

    let groupedOrders = Dictionary(grouping: orders, by: { $0.customer })

    let paidSums = orders
        .filter { $0.isPaid }
        .reduce(into: [String: Double]()) { result, order in
            result[order.customer, default: 0] += order.amount
        }

    let topCustomer = paidSums.max { $0.value < $1.value }

    print(paidAmounts)
    print(unpaidTotal)
    print(customers)
    print(promoCodes)
    print(groupedOrders)

    if let topCustomer {
        print(topCustomer.key)
        print(topCustomer.value)
    }
}
