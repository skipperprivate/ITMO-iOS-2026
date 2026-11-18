struct Order {
    let id: Int
    let customer: String
    let amount: Double // сумма заказа
    let isPaid: Bool
    let promoCode: String? // может отсутствовать
}
