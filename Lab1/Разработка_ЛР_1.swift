import Playgrounds

// ЗАДАЧА 1. Работа с заказами

struct Order {
    let id: Int
    let customer: String
    let amount: Double
    let isPaid: Bool
    let promoCode: String?
}


// ЗАДАЧА 2. Point

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    mutating func move(byX: Double, byY: Double) {
        x += byX
        y += byY
    }

    var distanceToOrigin: Double {
        return (x * x + y * y).squareRoot()
    }
}


// ЗАДАЧА 2. Rectangle

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    var area: Double {
        return width * height
    }

    var perimeter: Double {
        return 2 * (width + height)
    }

    var center: Point {
        return Point(
            x: origin.x + width / 2,
            y: origin.y + height / 2
        )
    }

    mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        return point.x >= origin.x &&
               point.x <= origin.x + width &&
               point.y >= origin.y &&
               point.y <= origin.y + height
    }

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
    }
}


// ЗАДАЧА 3. Очередь с приоритетом

struct PriorityQueue {

    struct Element {
        let value: String
        let priority: Int
    }

    private var elements: [Element] = []

    mutating func enqueue(_ value: String, priority: Int) {
        let element = Element(
            value: value,
            priority: priority
        )

        elements.append(element)
    }

    mutating func dequeue() -> String? {
        guard let highestPriority = elements.max(
            by: { $0.priority < $1.priority }
        ) else {
            return nil
        }

        guard let index = elements.firstIndex(
            where: {
                $0.priority == highestPriority.priority &&
                $0.value == highestPriority.value
            }
        ) else {
            return nil
        }

        return elements.remove(at: index).value
    }

    func peek() -> String? {
        return elements.max(
            by: { $0.priority < $1.priority }
        )?.value
    }

    var isEmpty: Bool {
        return elements.isEmpty
    }
}


// ЗАПУСК

#Playground {

    // ЗАДАЧА 1

    let orders: [Order] = [
        Order(
            id: 1,
            customer: "Анна",
            amount: 1200,
            isPaid: true,
            promoCode: "SALE10"
        ),
        Order(
            id: 2,
            customer: "Иван",
            amount: 800,
            isPaid: false,
            promoCode: nil
        ),
        Order(
            id: 3,
            customer: "Анна",
            amount: 5400,
            isPaid: true,
            promoCode: nil
        ),
        Order(
            id: 4,
            customer: "Олег",
            amount: 300,
            isPaid: true,
            promoCode: "NEW"
        ),
        Order(
            id: 5,
            customer: "Иван",
            amount: 2100,
            isPaid: false,
            promoCode: "SALE10"
        )
    ]


    // 1. Массив сумм оплаченных заказов

    let paidAmounts = orders
        .filter { $0.isPaid }
        .map { $0.amount }

    print("ЗАДАЧА 1")
    print("Суммы оплаченных заказов:", paidAmounts)


    // 2. Общая сумма неоплаченных заказов

    let unpaidTotal = orders
        .filter { !$0.isPaid }
        .reduce(0) { $0 + $1.amount }

    print("Сумма неоплаченных заказов:", unpaidTotal)


    // 3. Уникальные имена клиентов

    let uniqueCustomers = Array(
        Set(orders.map { $0.customer })
    ).sorted()

    print("Уникальные клиенты:", uniqueCustomers)


    // 4. Промокоды без nil

    let promoCodes = orders
        .compactMap { $0.promoCode }

    print("Промокоды:", promoCodes)


    // 5. Группировка заказов по клиентам

    let ordersByCustomer = Dictionary(
        grouping: orders,
        by: { $0.customer }
    )

    print("Заказы по клиентам:", ordersByCustomer)


    // 6. Клиент с максимальной оплаченной суммой

    let paidOrdersByCustomer = Dictionary(
        grouping: orders.filter { $0.isPaid },
        by: { $0.customer }
    )

    let customerWithMaxPaidAmount = paidOrdersByCustomer
        .map { customer, customerOrders in

            let total = customerOrders
                .reduce(0) { $0 + $1.amount }

            return (customer, total)
        }
        .max { $0.1 < $1.1 }

    print(
        "Клиент с максимальной оплаченной суммой:",
        customerWithMaxPaidAmount?.0 ?? "Нет данных",
        customerWithMaxPaidAmount?.1 ?? 0
    )


    // ЗАДАЧА 2

    print("")
    print("ЗАДАЧА 2")


    var point = Point(x: 3, y: 4)

    print("Исходная точка:", point)

    print(
        "Расстояние до начала координат:",
        point.distanceToOrigin
    )


    point.move(byX: 2, byY: 1)

    print("Точка после перемещения:", point)


    var rectangle = Rectangle(
        origin: Point(x: 0, y: 0),
        width: 100,
        height: 50
    )

    print("Площадь:", rectangle.area)

    print("Периметр:", rectangle.perimeter)

    print("Центр:", rectangle.center)


    print(
        "Точка (30, 20) внутри:",
        rectangle.contains(
            Point(x: 30, y: 20)
        )
    )


    print(
        "Точка (150, 20) внутри:",
        rectangle.contains(
            Point(x: 150, y: 20)
        )
    )


    rectangle.scale(by: 2)

    print("После масштабирования:")
    print("Ширина:", rectangle.width)
    print("Высота:", rectangle.height)


    // Проверка неправильных размеров

    let invalidRectangle = Rectangle(
        origin: Point(x: 0, y: 0),
        width: -10,
        height: 0
    )

    print("Проверка неправильных размеров:")
    print("Ширина:", invalidRectangle.width)
    print("Высота:", invalidRectangle.height)


    // ЗАДАЧА 3

    print("")
    print("ЗАДАЧА 3")


    var queue = PriorityQueue()


    queue.enqueue(
        "Обычная задача",
        priority: 1
    )

    queue.enqueue(
        "Важная задача",
        priority: 5
    )

    queue.enqueue(
        "Срочная задача",
        priority: 10
    )

    queue.enqueue(
        "Не очень важная задача",
        priority: 2
    )


    print(
        "Первый элемент:",
        queue.peek() ?? "Очередь пуста"
    )


    print(
        "Извлечён:",
        queue.dequeue() ?? "Очередь пуста"
    )

    print(
        "Извлечён:",
        queue.dequeue() ?? "Очередь пуста"
    )

    print(
        "Извлечён:",
        queue.dequeue() ?? "Очередь пуста"
    )

    print(
        "Извлечён:",
        queue.dequeue() ?? "Очередь пуста"
    )


    print(
        "Очередь пуста:",
        queue.isEmpty
    )
}
