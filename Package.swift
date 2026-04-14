// swift-tools-version:6.3

import PackageDescription

let package = Package(
    name: "PortfolioSite",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(url: "https://github.com/loopwerk/Saga", from: "3.3.2"),
        .package(url: "https://github.com/loopwerk/SagaParsleyMarkdownReader", from: "1.3.0"),
        .package(url: "https://github.com/loopwerk/SagaSwimRenderer", from: "1.4.1"),
        .package(url: "https://github.com/loopwerk/Moon", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "PortfolioSite",
            dependencies: [
                "Saga",
                "SagaParsleyMarkdownReader",
                "SagaSwimRenderer",
                "Moon",
                "ImageOptimizer",
            ],
            resources: [
                .copy("Resources/English.json"),
                .copy("Resources/Spanish.json"),
            ]
        ),
        .target(
            name: "ImageOptimizer"
        ),
    ]
)
