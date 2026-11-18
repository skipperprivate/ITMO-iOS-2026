func runTask3() {
    var pq = PriorityQueue<Int>()
    pq.push(item: 1, priority: 0)
    pq.push(item: 2, priority: 2)
    pq.push(item: 3, priority: 1)
    pq.push(item: 4, priority: 2)
    print(pq.pop())
    print(pq.pop())
    print(pq.pop())
    print(pq.pop())
    print(pq.pop())
}
