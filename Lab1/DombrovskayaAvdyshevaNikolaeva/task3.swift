struct SortedPriorityQueue<Element> {
    private var items: [Element] = []
    private let sort: (Element, Element) -> Bool
    
    init(sort: @escaping (Element, Element) -> Bool) {
        self.sort = sort
    }
    
    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }
    var peek: Element? { items.first }
    
    mutating func enqueue(_ element: Element) {
        let index = insertionIndex(for: element)
        items.insert(element, at: index)
    }
    
    mutating func dequeue() -> Element? {
        items.isEmpty ? nil : items.removeFirst()
    }
    
    private func insertionIndex(for element: Element) -> Int {
        var low = 0
        var high = items.count
        while low < high {
            let mid = (low + high) / 2
            if sort(element, items[mid]) {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
}

var minQueue = SortedPriorityQueue<Int> { $0 < $1 }

[5, 1, 9, 3, 7, 2].forEach { minQueue.enqueue($0) }

print(minQueue.peek!)

while let value = minQueue.dequeue() {
    print(value, terminator: " ")
}
