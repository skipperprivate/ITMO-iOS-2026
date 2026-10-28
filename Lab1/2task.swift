import Foundation

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    mutating func move(byX x: Double, byY y: Double) {
        self.x += x
        self.y += y
    }

    var distanceToOrigin: Double {
        return sqrt(x * x + y * y)
    }
}

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    var area: Double {
        return width * height
    }

    var perimeter: Double {
        return 2 * (width + height)
    }

    var center: Point {
        return Point(
            x: origin.x + width / 2,
            y: origin.y + height / 2
        )
    }

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin

        if width > 0 {
            self.width = width
        } else {
            self.width = 1.0
        }

        if height > 0 {
            self.height = height
        } else {
            self.height = 1.0
        }
    }

    mutating func scale(by factor: Double) {
        guard factor > 0 else {
            return
        }

        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        let minX = origin.x
        let maxX = origin.x + width
        let minY = origin.y
        let maxY = origin.y + height

        return point.x >= minX &&
               point.x <= maxX &&
               point.y >= minY &&
               point.y <= maxY
    }
}