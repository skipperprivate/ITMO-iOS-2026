import Foundation

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

print("==Получить массив сумм всех оплаченных заказов==")
let paidAmounts = orders
  .filter { $0.isPaid }
  .map { $0.amount }
print(paidAmounts)

print("==Найти общую сумму всех неоплаченных заказов (reduce)==")
let unpaidSum = orders
  .filter { !$0.isPaid }
  .reduce(0) { $0 + $1.amount }
print(unpaidSum)

print("==Получить список уникальных имён клиентов, отсортированный по алфавиту==")
let uniqueCustomers = 
      Array(
            Set(orders
                  .map {$0.customer}
               )
      ).sorted()
print(uniqueCustomers)

print("==Получить массив промокодов, исключив nil (compactMap)==")
let pomocodes = orders.compactMap { $0.promoCode }
print(pomocodes)

print("Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:))")
let ordersGroupedBy = Dictionary(
           grouping: orders, 
           by: { $0.customer }
          )
print(ordersGroupedBy)

print("Найти клиента с максимальной суммарной оплаченной суммой")
let topCustomer = ordersGroupedBy
  .mapValues { $0.reduce(0) { $0 + $1.amount } }
  .max { $0.value < $1.value }
print(topCustomer?.key ?? "топ покупатель не найден")



