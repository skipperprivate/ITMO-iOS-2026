struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    mutating func move(byX x: Double, byY y: Double) {
        self.x += x
        self.y += y
    }

    var distanceToOrigin: Double {
        return (x * x + y * y).squareRoot()
    }
}

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
    }

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

    mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        return point.x >= origin.x &&
               point.x <= origin.x + width &&
               point.y >= origin.y &&
               point.y <= origin.y + height
    }
}

func task2() {
    var point = Point(x: 3, y: 4)

    print(point.distanceToOrigin)

    point.move(byX: 2, byY: 1)

    print(point)

    var rectangle = Rectangle(
        origin: Point(x: 0, y: 0),
        width: 10,
        height: 5
    )

    print(rectangle.area)
    print(rectangle.perimeter)
    print(rectangle.center)
    print(rectangle.contains(Point(x: 3, y: 2)))

    rectangle.scale(by: 2)

    print(rectangle.width)
    print(rectangle.height)
}
