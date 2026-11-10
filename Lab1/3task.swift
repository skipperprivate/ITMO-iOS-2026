struct PriorityQueue<Element> {

    private var elements: [Element] = []

    private let priorityFunction: (Element, Element) -> Bool

    init(priorityFunction: @escaping (Element, Element) -> Bool) {
        self.priorityFunction = priorityFunction
    }

    var isEmpty: Bool {
        return elements.isEmpty
    }

    var count: Int {
        return elements.count
    }

    func peek() -> Element? {
        return elements.first
    }

    mutating func enqueue(_ element: Element) {
        elements.append(element)
        siftUp()
    }

    mutating func dequeue() -> Element? {
        if elements.isEmpty {
            return nil
        }

        if elements.count == 1 {
            return elements.removeLast()
        }

        let firstElement = elements[0]

        elements[0] = elements.removeLast()

        siftDown()

        return firstElement
    }

    private mutating func siftUp() {
        var childIndex = elements.count - 1

        while childIndex > 0 {
            let parentIndex = (childIndex - 1) / 2

            if priorityFunction(
                elements[childIndex],
                elements[parentIndex]
            ) {
                elements.swapAt(childIndex, parentIndex)
                childIndex = parentIndex
            } else {
                break
            }
        }
    }

    private mutating func siftDown() {
        var parentIndex = 0

        while true {
            let leftChildIndex = parentIndex * 2 + 1
            let rightChildIndex = parentIndex * 2 + 2

            var bestIndex = parentIndex

            if leftChildIndex < elements.count &&
                priorityFunction(
                    elements[leftChildIndex],
                    elements[bestIndex]
                ) {
                bestIndex = leftChildIndex
            }

            if rightChildIndex < elements.count &&
                priorityFunction(
                    elements[rightChildIndex],
                    elements[bestIndex]
                ) {
                bestIndex = rightChildIndex
            }

            if bestIndex == parentIndex {
                break
            }

            elements.swapAt(parentIndex, bestIndex)
            parentIndex = bestIndex
        }
    }
}