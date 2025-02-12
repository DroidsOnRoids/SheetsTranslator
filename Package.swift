// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SheetsTranslator",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SheetsTranslator",
            targets: ["SheetsTranslator"]
        )
    ],
    targets: [
        .target(
            name: "SheetsTranslator",
            path: "SheetsTranslator"
        )
    ]
)
