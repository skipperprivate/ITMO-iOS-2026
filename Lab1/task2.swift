import Foundation

// Point — структура с x, y типа Double:

// mutating func move(byX:byY:);

// вычисляемое свойство distanceToOrigin: Double;

// соответствие Equatable, Hashable.

// Rectangle — структура с origin: Point, width, height:

// вычисляемые свойства area, perimeter, center;

// mutating func scale(by factor: Double);

// func contains(_ point: Point) -> Bool;

// init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double
    
    var distanceToOrigin: Double {
        sqrt(x*x + y*y)
    }
    
    mutating func move(byX dx: Double, byY dy: Double) {
        x += dx
        y += dy
    }
}

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double
    
    var area: Double {
        width * height
    }
    
    var perimeter: Double {
        2 * (width + height)
    }
    
    var center: Point {
        Point(
            x: origin.x + width / 2,
            y: origin.y + height / 2
        )
    }
    
    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
    }
    
    mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }
    
    func contains(_ point: Point) -> Bool {
        point.x >= origin.x &&
        point.x <= origin.x + width &&
        point.y >= origin.y &&
        point.y <= origin.y + height
    }
}


// проверка
var p = Point(x: 3, y: 4)
print(p.distanceToOrigin)
p.move(byX: 1, byY: -1)
print(p)

var rect = Rectangle(origin: Point(x: 0, y: 0), width: -5, height: 10)
print(rect.width)
print(rect.height)

rect.scale(by: 2)
print(rect.area)
print(rect.center)
print(rect.contains(Point(x: 0.5, y: 5)))