import Foundation

struct Point: Hashable {
    var x: Double
    var y: Double
    
    var distanceToOrigin: Double {
        sqrt(x * x + y * y)
    }
    
    mutating func move(byX: Double, byY: Double) {
        x += byX
        y += byY
    }
}
