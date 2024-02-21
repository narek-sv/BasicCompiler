// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "BasicCompiler",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "BasicCompiler",
            dependencies: [],
            resources: [
                .process("_Resources/Localizable.xcstrings", localization: .base)
            ])
    ]
)
