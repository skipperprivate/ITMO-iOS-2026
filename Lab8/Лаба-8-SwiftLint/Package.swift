// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NewsLabCore",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [.library(name: "NewsLabCore", targets: ["NewsLabCore"])],
    targets: [
        .target(name: "NewsLabCore", path: "app", exclude: ["App", "Views", "Resources"]),
        .testTarget(name: "NewsLabCoreTests", dependencies: ["NewsLabCore"], path: "Tests"),
        .testTarget(name: "NewsNetworkTests", dependencies: ["NewsLabCore"], path: "appTests")
    ]
)
