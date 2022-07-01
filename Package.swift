// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ActionBuilderCore",
    
    platforms: [
        .macOS(.v12)
    ],
    
    products: [
        .library(
            name: "ActionBuilderCore",
            targets: ["ActionBuilderCore"]
        ),
        
    ],

    dependencies: [
        .package(url: "https://github.com/elegantchaos/XCTestExtensions", from: "1.4.7")
    ],

    targets: [
        .target(
            name: "ActionBuilderCore",
            dependencies: [
            ]
        ),

        .testTarget(
            name: "ActionBuilderCoreTests",
            dependencies: [
                "ActionBuilderCore",
                "XCTestExtensions"
            ]
        ),
    ]
)
