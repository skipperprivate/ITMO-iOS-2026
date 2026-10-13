import Foundation

struct RandomNumberModel {
    let range: ClosedRange<Int>

    init(range: ClosedRange<Int> = 0...100) {
        self.range = range
    }

    func generate() -> Int {
        Int.random(in: range)
    }
}
