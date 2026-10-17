import Foundation

// Реализовать очередь с приоритетом кастомную

class PriorityQueue<T> {
    struct Element {
        let value: T
        let priority: Int
    }
    
    var items: [Element]
    
    init() {
        self.items = []
    }
    
    func enqueue(_ value: T, _ priority: Int) {
        items.append(Element(value: value, priority: priority))
    }
    
    func dequeue() -> T? {
        guard let index = items.indices.max(by: { items[$0].priority < items[$1].priority })
        else { return nil }
        
        return items.remove(at: index).value
    }
}

let testQueue = PriorityQueue<Double>()
testQueue.enqueue(1.0, 10)
testQueue.enqueue(2.0, 15)
testQueue.enqueue(1.1, 10)
print(testQueue.dequeue()!)
print(testQueue.dequeue()!)
print(testQueue.dequeue()!)