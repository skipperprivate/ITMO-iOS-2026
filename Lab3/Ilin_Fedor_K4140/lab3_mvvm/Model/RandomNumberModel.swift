
struct RandomNumberModel {
    private(set) var value: Int = 0

    mutating func generate() {
        value = Int.random(in: 1...300)
    }
}
