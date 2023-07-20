// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "B2Api",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "B2Api",
            targets: ["B2Api"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kdeda/idd-log4-swift.git", from: "2.0.4"),
        .package(url: "github.com/pointfreeco/swift-composable-architecture.git", exact: "0.55.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", exact: "0.5.1")
    ],
    targets: [
        .target(
            name: "B2Api",
            dependencies: [
                .product(name: "Log4swift", package: "idd-log4-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            path: "Sources",
            resources: [
                .copy("_Caches")
            ]
        ),
        .testTarget(
            name: "B2ApiTests",
            dependencies: [
                "B2Api",
                .product(name: "Log4swift", package: "idd-log4-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        )
    ]
)
