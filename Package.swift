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
                "ActionBuilderCore"
            ]
        ),
    ]
)
