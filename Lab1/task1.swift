// struct Order {
// let id: Int
// let customer: String
// let amount: Double // сумма заказа
// let isPaid: Bool
// let promoCode: String? // может отсутствовать
// }

// let orders: [Order] = [
// Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
// Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
// Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
// Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
// Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
// ]

// Получить массив сумм всех оплаченных заказов.

// Найти общую сумму всех неоплаченных заказов (reduce).

// Получить список уникальных имён клиентов, отсортированный по алфавиту.

// Получить массив промокодов, исключив nil (compactMap).

// Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).

// Найти клиента с максимальной суммарной оплаченной суммой.
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

let paidAmounts = orders
                  .filter { $0.isPaid }
                  .map { $0.amount }

print(paidAmounts)

let noPaidSum = orders
                  .filter { !$0.isPaid }
                  .reduce(0) { $0 + $1.amount }

print(noPaidSum)

let nameSet = Set(orders.map { $0.customer })
                    .sorted()

print(nameSet)

let promoArray = orders
                    .compactMap { $0.promoCode }
                    
print(promoArray)

let ordersByCustomer = Dictionary(grouping: orders, by: { $0.customer })

print(ordersByCustomer)

let paidTotalByCustomer = ordersByCustomer
    .mapValues { customerOrders in
        customerOrders
            .filter { $0.isPaid }
            .reduce(0) { $0 + $1.amount }
    }
    
print(paidTotalByCustomer)

let maxPaid = paidTotalByCustomer
                .max { $0.value < $1.value }?
                .key
                
print(maxPaid!)