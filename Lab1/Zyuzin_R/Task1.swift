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

var paidOrders = orders.filter { order in
    order.isPaid
} //Массив сумм всех оплаченных заказов

paidOrders.forEach{order in print((String(order.id) + (" " + order.customer)))}

var unpaidSum = orders // Сумма всех неоплаченных заказов
                    .filter{ order in !order.isPaid}
                    .reduce(0, {partialSum, orderX in 
                        partialSum + orderX.amount
                    })
                    
print(unpaidSum)

var customers = Set(orders.map{$0.customer}).sorted() //Все уникальные клиенты по алфавиту
print(customers)

var promoCodes = orders.compactMap{order in //Все ненулевые промокоды
    order.promoCode}
    
print(promoCodes)

// Сгрупированные по имени клиента заказы
var groupedOrdersDict = Dictionary(grouping: orders, by: { $0.customer })

print(groupedOrdersDict)

//Поиск клиента с MAX оплаченной суммой
var maxCustomerSum = (name: "Name", sum: 0)
groupedOrdersDict.forEach{ (key, value) in
    var paidCustomerOrdersSum = Int(value.filter{order in
            order.isPaid
        }.reduce(0, {partialSum, orderX in 
                        partialSum + orderX.amount
        }))
    if paidCustomerOrdersSum > maxCustomerSum.sum {
        maxCustomerSum = (name: key, sum: paidCustomerOrdersSum)
        
    }
}

print(maxCustomerSum)