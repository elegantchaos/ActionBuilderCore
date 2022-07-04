// swift-tools-version:5.6

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "ExamplePackage",
    
    platforms: [
        .macOS(.v12), .iOS(.v14), .tvOS(.v14)
    ],
    
    products: [
        .library(
            name: "ExamplePackage",
            targets: ["ExamplePackage"]
        ),
        
    ],

    dependencies: [
    ],

    targets: [
        .target(
            name: "ExamplePackage",
            dependencies: [
            ]
        ),
    ]
)
