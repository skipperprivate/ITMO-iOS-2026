func runTask2() {
    //mutating func move(byX:byY:);
    var p = Point(x: 1, y: 1)
    p.move(byX: 1, byY: 2)
    print(p)

    //вычисляемое свойство distanceToOrigin: Double;
    print(p.distanceToOrigin)

    //соответствие Equatable, Hashable.
    let p1 = Point(x: 1, y: 1)
    let p2 = Point(x: 1, y: 1)
    print(p1 == p2)

    let s = Set([p1, p2])
    print(s)

    //вычисляемые свойства area, perimeter, center;
    var r = Rectangle(origin: Point(x:0, y:1), width: 2, height: 3)
    print(r)
    print(r.area)
    print(r.center)
    print(r.perimeter)

    //mutating func scale(by factor: Double);
    r.scale(by: 5)
    print(r)

    //func contains(_ point: Point) -> Bool;
    print(r.contains(Point(x: 1, y: 5)))
    print(r.contains(Point(x: -1, y: -5)))

    //init с валидацией: если width <= 0 или height <= 0 — использовать значения по умолчанию 1.0.
    let r3 = Rectangle(origin: Point(x:0, y:1), width: -2, height: -3)
    print(r3)
}
