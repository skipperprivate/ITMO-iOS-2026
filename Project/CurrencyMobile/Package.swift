// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CurrencyMobile",
    platforms: [
        .iOS(.v17), .macOS(.v14),
    ],
    products: [
        .library(name: "CurrencyCore", targets: ["CurrencyCore"]),
    ],
    targets: [
        //  Зависимостей нет: только Foundation.
        .target(name: "CurrencyCore"),
        .testTarget(name: "CurrencyCoreTests",
                    dependencies: ["CurrencyCore"]),
    ]
)
