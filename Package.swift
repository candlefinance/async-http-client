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
    name: "candle-async-http-client",
    products: [
        .library(name: "CandleAsyncHTTPClient", targets: ["CandleAsyncHTTPClient"])
    ],
    dependencies: [
        .package(name: "candle-swift-nio", url: "https://github.com/candlefinance/candle-swift-nio.git", branch: "fix-candle-2.82.1"),
        .package(name: "candle-swift-nio-ssl", url: "https://github.com/candlefinance/candle-swift-nio-ssl.git", branch: "fix-candle-2.33.0"),
        .package(name: "candle-swift-nio-http2", url: "https://github.com/candlefinance/candle-swift-nio-http2.git", branch: "fix-candle-1.38.0"),
        .package(name: "candle-swift-nio-extras", url: "https://github.com/candlefinance/candle-swift-nio-extras.git", branch: "fix-candle-1.29.0"),
        .package(name: "candle-swift-nio-transport-services", url: "https://github.com/candlefinance/candle-swift-nio-transport-services.git", branch: "fix-candle-1.24.0"),
        .package(name: "candle-swift-log", url: "https://github.com/candlefinance/candle-swift-log.git", branch: "fix-candle-1.6.3"),
        .package(name: "candle-swift-atomics", url: "https://github.com/candlefinance/candle-swift-atomics.git", branch: "fix-candle-1.2.0"),
        .package(name: "candle-swift-algorithms", url: "https://github.com/candlefinance/candle-swift-algorithms.git", branch: "fix-candle-1.2.1"),
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
                .product(name: "CandleNIO", package: "candle-swift-nio"),
                .product(name: "CandleNIOTLS", package: "candle-swift-nio"),
                .product(name: "CandleNIOCore", package: "candle-swift-nio"),
                .product(name: "CandleNIOPosix", package: "candle-swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "candle-swift-nio"),
                .product(name: "CandleNIOConcurrencyHelpers", package: "candle-swift-nio"),
                .product(name: "CandleNIOHTTP2", package: "candle-swift-nio-http2"),
                .product(name: "CandleNIOSSL", package: "candle-swift-nio-ssl"),
                .product(name: "CandleNIOHTTPCompression", package: "candle-swift-nio-extras"),
                .product(name: "CandleNIOSOCKS", package: "candle-swift-nio-extras"),
                .product(name: "CandleNIOTransportServices", package: "candle-swift-nio-transport-services"),
                .product(name: "CandleLogging", package: "candle-swift-log"),
                .product(name: "CandleAtomics", package: "candle-swift-atomics"),
                .product(name: "CandleAlgorithms", package: "candle-swift-algorithms"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "AsyncHTTPClientTests",
            dependencies: [
                .target(name: "CandleAsyncHTTPClient"),
                .product(name: "CandleNIOTLS", package: "candle-swift-nio"),
                .product(name: "CandleNIOCore", package: "candle-swift-nio"),
                .product(name: "CandleNIOConcurrencyHelpers", package: "candle-swift-nio"),
                .product(name: "CandleNIOEmbedded", package: "candle-swift-nio"),
                .product(name: "CandleNIOFoundationCompat", package: "candle-swift-nio"),
                .product(name: "NIOTestUtils", package: "candle-swift-nio"),
                .product(name: "CandleNIOSSL", package: "candle-swift-nio-ssl"),
                .product(name: "CandleNIOHTTP2", package: "candle-swift-nio-http2"),
                .product(name: "CandleNIOSOCKS", package: "candle-swift-nio-extras"),
                .product(name: "CandleLogging", package: "candle-swift-log"),
                .product(name: "CandleAtomics", package: "candle-swift-atomics"),
                .product(name: "CandleAlgorithms", package: "candle-swift-algorithms"),
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
