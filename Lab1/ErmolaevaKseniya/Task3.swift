//Реализовать очередь с приоритетом кастомную

struct PriorityQueueElement<T> { // T - generic
    let value: T
    let priority: Int
}

struct PriorityQueue<T> {
    private var elements: [PriorityQueueElement<T>]

    init() {
        self.elements = []
    }

    var isQueueEmpty: Bool { elements.isEmpty }

    var size: Int { elements.count }

    mutating func enqueue(_ element: T, _ priority: Int) {
        elements.append(
            PriorityQueueElement(
                value: element,
                priority: priority
            )
        )

        elements.sort { // по убыванию приоритета
            $0.priority > $1.priority
        }
    }

    mutating func dequeue() -> T? {
        guard !isQueueEmpty else { return nil }

        return elements.removeFirst().value // возвращаем удалённый
    }

    func peek() -> T? { // можно без guard 
        return elements.first?.value
    }
}

// TEST
var queue = PriorityQueue<String>()
print("Очередь пустая: \(queue.isQueueEmpty)")
print("Размер очереди: \(queue.size)")

queue.enqueue("Обычная", 1)
queue.enqueue("Срочная", 10)
queue.enqueue("Средняя", 5)

print("\nПосле добавления элементов:")
print("Размер очереди: \(queue.size)")
print("Очередь пустая: \(queue.isQueueEmpty)")

print("\nПервый элемент: \(queue.peek() ?? "Очередь пустая")")

print("\nУдаляем элементы:")
print(queue.dequeue() ?? "Очередь пустая")
print(queue.dequeue() ?? "Очередь пустая")
print(queue.dequeue() ?? "Очередь пустая")

print("\nПосле удаления:")
print("Размер очереди: \(queue.size)")
print("Очередь пустая: \(queue.isQueueEmpty)")

print("Попытка удалить из пустой очереди: \(queue.dequeue() ?? "Очередь пустая")")
