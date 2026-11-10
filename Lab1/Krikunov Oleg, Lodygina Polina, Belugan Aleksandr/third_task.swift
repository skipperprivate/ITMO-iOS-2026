/*
 Реализовать очередь с приоритетом кастомную
 */

struct PriorityQueue<Element> {
    private var elements: [(value: Element, priority: Int)] = []

    var isEmpty: Bool {
        elements.isEmpty
    }

    var count: Int {
        elements.count
    }

    mutating func enqueue(_ element: Element, priority: Int) {
        let index = elements.firstIndex {
            $0.priority < priority
        } ?? elements.endIndex

        elements.insert(
            (value: element, priority: priority),
            at: index
        )
    }

    mutating func dequeue() -> Element? {
        guard !isEmpty else { return nil }

        return elements.removeFirst().value
    }

    func peek() -> Element? {
        elements.first?.value
    }
}

var queue = PriorityQueue<String>()

queue.enqueue("Обычная задача", priority: 1)
queue.enqueue("Срочная задача", priority: 3)
queue.enqueue("Средняя задача", priority: 2)
queue.enqueue("Ещё одна срочная задача", priority: 3)

print(queue.count)
print(queue.peek() ?? "Очередь пуста")

while let task = queue.dequeue() {
    print(task)
}

print(queue.isEmpty) // true
