struct PriorityQueue<T> {
    var items: Array<PriorityQueueItem<T>> = []
    
    mutating func push(item: T, priority: Int) {
        items.append(PriorityQueueItem(item: item, priority: priority))
    }
    
    mutating func pop() -> Optional<T> {
        guard let maxItemIdx = items.indices.max(by: {items[$0].priority < items[$1].priority}) else {
            return nil
        }
        return items.remove(at: maxItemIdx).item
    }
}
