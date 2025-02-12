// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SheetsTranslator",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SheetsTranslator",
            targets: ["SheetsTranslator"])
    ],
    targets: [
        .target(
            name: "SheetsTranslator",
            dependencies: [],
            path: "SheetsTranslator",
            exclude: ["main.swift"])
    ]
)