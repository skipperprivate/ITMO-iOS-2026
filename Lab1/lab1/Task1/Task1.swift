func runTask1() {
    let orders: [Order] = [
        Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
        Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
        Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
        Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
        Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
    ]
    
    
    let paidOrdersAmounts = orders.filter{$0.isPaid}.map{$0.amount}
    print("Получить массив сумм всех оплаченных заказов:", paidOrdersAmounts, terminator: "\n\n")
    
    let notPaidSumAmount = orders.filter{!$0.isPaid}.reduce(0){$0 + $1.amount}
    print("Найти общую сумму всех неоплаченных заказов (reduce):", notPaidSumAmount, terminator: "\n\n")
    
    let uniqueClientNames = Set(orders.map{$0.customer}).sorted(by: { $0 < $1})
    print("Получить список уникальных имён клиентов, отсортированный по алфавиту:", uniqueClientNames, terminator: "\n\n")
    
    let promocodes = orders.compactMap{$0.promoCode}
    print("Получить массив промокодов, исключив nil (compactMap):", promocodes, terminator: "\n\n")
    
    let clientNameToOrders = Dictionary(grouping: orders, by: {$0.customer})
    print("Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)):\n", clientNameToOrders, terminator: "\n\n")
    
    print("Найти клиента с максимальной суммарной оплаченной суммой.")
    let topClient = clientNameToOrders.map {
        (name: $0, sumAmount: $1.filter{$0.isPaid}.reduce(0){$0 + $1.amount})
    } .max {$0.sumAmount < $1.sumAmount}
    print(topClient!)
}
