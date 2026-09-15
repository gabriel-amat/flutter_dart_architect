// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "native_crypto",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "native_crypto",
            targets: ["native_crypto"]
        ),
    ],
    targets: [
        .target(
            name: "native_crypto",
            path: "src",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
    ]
)
