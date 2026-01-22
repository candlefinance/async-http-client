// swift-tools-version:5.10
//===----------------------------------------------------------------------===//
//
// This source file is part of the AsyncHTTPClient open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the AsyncHTTPClient project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of AsyncHTTPClient project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let strictConcurrencyDevelopment = false

let strictConcurrencySettings: [SwiftSetting] = {
    var initialSettings: [SwiftSetting] = []
    initialSettings.append(contentsOf: [
        .enableUpcomingFeature("StrictConcurrency"),
        .enableUpcomingFeature("InferSendableFromCaptures"),
    ])

    if strictConcurrencyDevelopment {
        // -warnings-as-errors here is a workaround so that IDE-based development can
        // get tripped up on -require-explicit-sendable.
        initialSettings.append(.unsafeFlags(["-Xfrontend", "-require-explicit-sendable", "-warnings-as-errors"]))
    }

    return initialSettings
}()

let package = Package(
    name: "async-http-client",
    products: [
        .library(name: "CandleAsyncHTTPClient", targets: ["CandleAsyncHTTPClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/candlefinance/swift-nio.git", branch: "fix-candle-2.82.1"),
        .package(url: "https://github.com/candlefinance/swift-nio-ssl.git", branch: "fix-candle-2.30.0"),
        .package(url: "https://github.com/candlefinance/swift-nio-http2.git", branch: "fix-candle-1.38.0"),
        .package(url: "https://github.com/candlefinance/swift-nio-extras.git", branch: "fix-candle-1.29.0"),
        .package(url: "https://github.com/candlefinance/swift-nio-transport-services.git", branch: "fix-candle-1.24.0"),
        .package(url: "https://github.com/candlefinance/swift-log.git", branch: "fix-candle-1.6.3"),
        .package(url: "https://github.com/candlefinance/swift-atomics.git", branch: "fix-candle-1.2.0"),
        .package(url: "https://github.com/candlefinance/swift-algorithms.git", branch: "fix-candle-1.2.1"),
    ],
    targets: [
        .target(
            name: "CandleCAsyncHTTPClient",
            cSettings: [
                .define("_GNU_SOURCE")
            ]
        ),
        .target(
            name: "CandleAsyncHTTPClient",
            dependencies: [
                .target(name: "CandleCAsyncHTTPClient"),
                .product(name: "CandleNIO", package: "swift-nio"),
                .product(name: "CandleNIOTLS", package: "swift-nio"),
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOPosix", package: "swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "swift-nio"),
                .product(name: "CandleNIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "CandleNIOHTTP2", package: "swift-nio-http2"),
                .product(name: "CandleNIOSSL", package: "swift-nio-ssl"),
                .product(name: "CandleNIOHTTPCompression", package: "swift-nio-extras"),
                .product(name: "CandleNIOSOCKS", package: "swift-nio-extras"),
                .product(name: "CandleNIOTransportServices", package: "swift-nio-transport-services"),
                .product(name: "CandleLogging", package: "swift-log"),
                .product(name: "CandleAtomics", package: "swift-atomics"),
                .product(name: "CandleAlgorithms", package: "swift-algorithms"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AsyncHTTPClientTests",
            dependencies: [
                .target(name: "CandleAsyncHTTPClient"),
                .product(name: "CandleNIOTLS", package: "swift-nio"),
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "CandleNIOEmbedded", package: "swift-nio"),
                .product(name: "CandleNIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOTestUtils", package: "swift-nio"),
                .product(name: "CandleNIOSSL", package: "swift-nio-ssl"),
                .product(name: "CandleNIOHTTP2", package: "swift-nio-http2"),
                .product(name: "CandleNIOSOCKS", package: "swift-nio-extras"),
                .product(name: "CandleLogging", package: "swift-log"),
                .product(name: "CandleAtomics", package: "swift-atomics"),
                .product(name: "CandleAlgorithms", package: "swift-algorithms"),
            ],
            resources: [
                .copy("Resources/self_signed_cert.pem"),
                .copy("Resources/self_signed_key.pem"),
                .copy("Resources/example.com.cert.pem"),
                .copy("Resources/example.com.private-key.pem"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)

// ---    STANDARD CROSS-REPO SETTINGS DO NOT EDIT   --- //
for target in package.targets {
    switch target.type {
    case .regular, .test, .executable:
        var settings = target.swiftSettings ?? []
        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
        settings.append(.enableUpcomingFeature("MemberImportVisibility"))
        target.swiftSettings = settings
    case .macro, .plugin, .system, .binary:
        ()  // not applicable
    @unknown default:
        ()  // we don't know what to do here, do nothing
    }
}
// --- END: STANDARD CROSS-REPO SETTINGS DO NOT EDIT --- //
