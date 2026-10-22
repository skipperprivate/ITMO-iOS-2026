struct PriorityQueue<Element> {
    private var items: [(value: Element, priority: Int)] = []

    var isEmpty: Bool {
        return items.isEmpty
    }

    var count: Int {
        return items.count
    }

    mutating func enqueue(_ value: Element, priority: Int) {
        items.append((value, priority))
        items.sort { $0.priority > $1.priority }
    }

    mutating func dequeue() -> Element? {
        if items.isEmpty {
            return nil
        }

        return items.removeFirst().value
    }

    func peek() -> Element? {
        return items.first?.value
    }
}

func task3() {
    var queue = PriorityQueue<String>()

    queue.enqueue("Низкий", priority: 1)
    queue.enqueue("Высокий", priority: 10)
    queue.enqueue("Средний", priority: 5)

    print(queue.peek() ?? "")

    while !queue.isEmpty {
        print(queue.dequeue() ?? "")
    }
}
