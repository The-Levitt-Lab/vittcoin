// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VittcoinDependencies",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VittcoinDependencies",
            targets: ["VittcoinDependencies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "VittcoinDependencies",
            dependencies: [
                .product(name: "PostHog", package: "posthog-ios")
            ],
            path: "Dependencies"
        )
    ]
)
