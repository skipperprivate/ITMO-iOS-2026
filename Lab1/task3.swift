struct PriorityQueue<Element> {
    private var elements: [Element] = []
    private let areInPriorityOrder: (Element, Element) -> Bool

    init(sort: @escaping (Element, Element) -> Bool) {
        areInPriorityOrder = sort
    }

    var isEmpty: Bool { elements.isEmpty }
    var count: Int { elements.count }

    func peek() -> Element? {
        elements.first
    }

    mutating func enqueue(_ element: Element) {
        elements.append(element)
        var child = elements.count - 1

        while child > 0 {
            let parent = (child - 1) / 2
            guard areInPriorityOrder(elements[child], elements[parent]) else { break }
            elements.swapAt(child, parent)
            child = parent
        }
    }

    mutating func dequeue() -> Element? {
        guard !isEmpty else { return nil }
        if elements.count == 1 {
            return elements.removeLast()
        }

        elements.swapAt(0, elements.count - 1)
        let result = elements.removeLast()
        var parent = 0

        while true {
            let left = parent * 2 + 1
            let right = left + 1
            var candidate = parent

            if left < elements.count,
               areInPriorityOrder(elements[left], elements[candidate]) {
                candidate = left
            }
            if right < elements.count,
               areInPriorityOrder(elements[right], elements[candidate]) {
                candidate = right
            }
            guard candidate != parent else { break }
            elements.swapAt(parent, candidate)
            parent = candidate
        }

        return result
    }
}

var queue = PriorityQueue<Int>(sort: >)
queue.enqueue(3)
queue.enqueue(10)
queue.enqueue(1)
queue.enqueue(5)

while let element = queue.dequeue() {
    print(element) // 10, 5, 3, 1
}
