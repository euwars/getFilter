// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/IBM-Swift/Kitura", .exact("2.4.1")),
         .package(url: "https://github.com/OpenKitten/MongoKitten", .exact("4.1.3")),
         .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.3.4")),
         .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .exact("0.10.0")),
         ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Backend",
            dependencies: ["Kitura", "MongoKitten", "PromiseKit", "CryptoSwift"]),
    ]
)
