// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TVNExtensions",
    platforms: [
        .iOS(.v13), .macOS(.v10_14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TVNExtensionsFoundation",
            targets: ["TVNExtensionsFoundation"]),
        .library(
            name: "TVNExtensionsUIKit",
            targets: ["TVNExtensionsUIKit"]),
        .library(
            name: "TVNExtensionsRx",
            targets: ["TVNExtensionsRx"]),
        .library(
            name: "ParticleIOS",
            targets: ["ParticleIOS"]),
        .library(
            name: "TlvParser",
            targets: ["TlvParser"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, fro: "1.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.6.0")
    ],
    targets: [
        .target(
            name: "TVNExtensionsFoundation",
            path: "Sources/Foundation"),
        .target(
            name: "TVNExtensionsUIKit",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/UIKit"),
        
        .target(
            name: "TVNExtensionsRx",
            dependencies:[
                "TVNExtensionsUIKit",
                "TVNExtensionsFoundation",
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Rx"),
        .target(
            name: "TlvParser",
            path: "TlvParser"),
        .target(
            name: "ParticleIOS",
            dependencies: [
                "TVNExtensionsFoundation",
                "TVNExtensionsUIKit"
            ],
            path: "ParticleIOS"),
    ]
)
