// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Motibar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Motibar", targets: ["Motibar"])
    ],
    targets: [
        .executableTarget(
            name: "Motibar",
            path: "Sources/Motibar"
        )
    ]
)
