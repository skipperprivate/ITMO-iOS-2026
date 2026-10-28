struct Order {
  let id: Int
  let customer: String
  let amount: Double  // сумма заказа
  let isPaid: Bool
  let promoCode: String?  // может отсутствовать
}

let orders: [Order] = [
  Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
  Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
  Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
  Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
  Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10"),
]

// Получить массив сумм всех оплаченных заказов.
let arr =
  orders
  .filter { $0.isPaid }
  .map { $0.amount }
print(arr)

// Найти общую сумму всех неоплаченных заказов (reduce).
let sum = orders.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
print(sum)

// Получить список уникальных имён клиентов, отсортированный по алфавиту.
let uniqueNames = Set(orders.map { $0.customer }).sorted()
print(uniqueNames)

// Получить массив промокодов, исключив nil (compactMap).
let promo = orders.compactMap { $0.promoCode }
print(promo)

// Сгруппировать заказы по имени клиента в словарь [String: [Order]] (через Dictionary(grouping:by:)).
let groupNames = Dictionary(grouping: orders) { $0.customer }
print(groupNames)

// Найти клиента с максимальной суммарной оплаченной суммой.
let sorted = orders.filter { $0.isPaid }
let top = Dictionary(grouping: sorted) { $0.customer }
  .mapValues { $0.reduce(0, { $0 + $1.amount }) }

let topCustomer = top.max(by: { $0.value < $1.value })
print(topCustomer)
