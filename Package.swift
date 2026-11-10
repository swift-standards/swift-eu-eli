// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-eu-eli",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "EU ELI", targets: ["EU ELI"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-iso/swift-iso-3166.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-639.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-8601.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-6570.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "EU ELI",
            dependencies: [
                .product(name: "ISO 3166", package: "swift-iso-3166"),
                .product(name: "ISO 639", package: "swift-iso-639"),
                .product(name: "ISO 8601", package: "swift-iso-8601"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 6570", package: "swift-rfc-6570"),
            ]
        ),
        .testTarget(
            name: "EU ELI Tests",
            dependencies: [
                .target(name: "EU ELI")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
