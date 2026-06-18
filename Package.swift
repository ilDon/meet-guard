// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MeetGuard",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MeetGuard", targets: ["MeetGuard"])
    ],
    targets: [
        .executableTarget(
            name: "MeetGuard",
            path: "Sources/MeetGuard"
        ),
        .testTarget(
            name: "MeetGuardTests",
            dependencies: ["MeetGuard"],
            path: "Tests/MeetGuardTests"
        )
    ]
)
