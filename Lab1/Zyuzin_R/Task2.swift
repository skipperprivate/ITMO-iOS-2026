import Foundation

struct Point{
//Примитивные типы соответсвуют протоколам Equatable и Hashable по умолчанию
    var x: Double = 0.0
    var y: Double = 0.0
    var distanceToOrigin: Double = 0.0
    
    mutating func move(byX: Double, byY: Double){
        x += byX
        y += byY
        
        distanceToOrigin = sqrt(pow(x, 2.0) + pow(y, 2.0))
    }
}

struct Rectangle{
    var origin: Point = Point()
    var width: Double = 1.0
    var height: Double = 1.0
    var area: Double = 1.0
    var perimeter: Double = 1.0
    var center: Double = 0.5
    
    mutating func scale(byFactor: Double){
        origin.move(byX: 2.0, byY: 2.0)
        center *= abs(byFactor) //Отрицательным быть не может (увеличение > 1, уменьшение от 0 до 1)
        area = pow(2*center, 2.0)
        perimeter = abs(8*center)
        
        width = 2*center
        height = width
    }
    
    mutating func contains(point: Point) -> Bool{
    //В swift нельзя делать if без фигурных скобок даже в одну строку?
        if (point.x < origin.x || point.y < origin.y){
            return false
        }
            
        if ((origin.x + height) < point.x || (origin.y + width) < point.y){
            return false
        }
            
        return true
    }
    
    mutating func printRectData(){
        print("Start point:(\(origin.x), \(origin.y)) width: \(width) height: \(height) center:\(center) area:\(area) perimeter:\(perimeter)")
    }
    
    init(){
        if width <= 0{
            width = 1.0
        }
        if height <= 0{
            height = 1.0
        }
    }
}

var rect = Rectangle()
rect.scale(byFactor: 2)
rect.printRectData()
print(rect.contains(point: Point(x: 3.0, y: 4.0)))
print(rect.contains(point: Point(x: -3.0, y: -4.0)))
print(rect.contains(point: Point(x: 3.1, y: 3.5)))


