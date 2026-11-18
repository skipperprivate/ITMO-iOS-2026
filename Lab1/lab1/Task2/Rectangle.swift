struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double
    
    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1
        self.height = height > 0 ? height : 1
    }
    
    var area: Double {
        width * height
    }
    
    var perimeter: Double {
        width * 2 + height * 2
    }
    
    var center: Point {
        Point(x: origin.x + width / 2, y: origin.y + height / 2)
    }
    
    mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }
    
    func contains(_ point: Point) -> Bool {
        origin.x <= point.x && point.x <= origin.x + width &&
        origin.y <= point.y && point.y <= origin.y + height
    }
}
