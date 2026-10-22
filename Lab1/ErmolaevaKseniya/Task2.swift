import Foundation // для sqrt

/*Point — структура с x, y типа Double:  
mutating func move(byX:byY:);  
вычисляемое свойство distanceToOrigin: Double;  
соответствие Equatable, Hashable. 
*/

struct Point: Equatable, Hashable { 
    var x: Double 
    var y: Double

    var distanceToOrigin: Double {
        sqrt(x * x + y * y) // return необязателен
    }

    mutating func move(byX dx: Double, byY dy: Double) { 
        // byX, byY - внешние имена параметров 
        
        x += dx
        y += dy
    }  
}


/*Rectangle — структура с origin: Point, width, height:  
вычисляемые свойства area, perimeter, center;  
mutating func scale(by factor: Double);  
func contains(_ point: Point) -> Bool;  
init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.
*/

struct Rectangle {
    var origin: Point
    var width: Double 
    var height: Double 

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0.0 ? width : 1.0
        self.height = height > 0.0 ? height : 1.0
    }

    var area: Double { width * height }

    var perimeter: Double { 2*(width + height) }

    var center: Point {
        Point(
            x: origin.x + width/2,
            y: origin.y + height/2
        )
    }

    mutating func scale(by factor: Double) { 
        guard factor > 0 else {
            return
        }

        width *= factor
        height *= factor
    }  

    func contains(_ point: Point) -> Bool {
        point.x > origin.x && 
        point.x < origin.x + width && 
        point.y > origin.y && 
        point.y < origin.y + height
    }

}


// TEST Point
var point = Point(x: 3, y: 4)

print("Точка: (\(point.x), \(point.y))")
print("Расстояние до начала координат: \(point.distanceToOrigin)")

point.move(byX: 2, byY: -1)
print("После перемещения: (\(point.x), \(point.y))")

let anotherPoint = Point(x: 5, y: 3)
print("Точки равны: \(point == anotherPoint)")


// TEST Rectangle
var rectangle = Rectangle(
    origin: Point(x: 2, y: 3),
    width: 6,
    height: 4
)
print("\nПлощадь прямоугольника: \(rectangle.area)")
print("Периметр: \(rectangle.perimeter)")
print("Центр: (\(rectangle.center.x), \(rectangle.center.y))")

let point2 = Point(x: 4, y: 5)
print("Точка внутри: \(rectangle.contains(point2))")

rectangle.scale(by: 2)
print("После масштабирования:")
print("Ширина: \(rectangle.width)")
print("Высота: \(rectangle.height)")

let invalidRectangle = Rectangle(
    origin: Point(x: 0, y: 0),
    width: -5,
    height: 0
)
print(invalidRectangle.width)
print(invalidRectangle.height)
rectangle.scale(by: -2)
