//Реализовать очередь с приоритетом кастомную
// 2ой вариант (более оптимальный)

struct PriorityQueueElement<T> {
    let value: T
    let priority: Int
}

struct PriorityQueue<T> {
    private var elements: [PriorityQueueElement<T>] = []

    var isQueueEmpty: Bool {
        elements.isEmpty
    }

    var size: Int {
        elements.count
    }

    mutating func enqueue(_ element: T, _ priority: Int) {
        elements.append(
            PriorityQueueElement(
                value: element,
                priority: priority
            )
        )
    }

    mutating func dequeue() -> T? {
        guard !isQueueEmpty else {
            return nil
        }

        let maxPriority = elements.map { $0.priority }.max()

        guard let index = elements.firstIndex(where: {
            $0.priority == maxPriority
        }) else {
            return nil
        }

        return elements.remove(at: index).value
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

print("\nУдаляем элементы:")
print(queue.dequeue() ?? "Очередь пустая")
print(queue.dequeue() ?? "Очередь пустая")
print(queue.dequeue() ?? "Очередь пустая")

print("\nПосле удаления:")
print("Размер очереди: \(queue.size)")
print("Очередь пустая: \(queue.isQueueEmpty)")

print("Попытка удалить из пустой очереди: \(queue.dequeue() ?? "Очередь пустая")")

