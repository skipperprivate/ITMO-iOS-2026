import Foundation

actor EvenNumberChecker {
    private(set) var sum: Int = 0
    private(set) var evenCount: Int = 0
    
    func check(_ number: Int) -> Bool {
        guard number % 2 == 0 else { return false }
        sum += number
        evenCount += 1
        return true
    }
    
    func reset() {
        sum = 0
        evenCount = 0
    }
}
