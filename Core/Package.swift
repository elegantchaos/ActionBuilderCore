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
        
        .library(
            name: "ActionBuilderUI",
            targets: ["ActionBuilderUI"]
        ),
        
        .executable(
            name: "ActionBuilderTool",
            targets: ["ActionBuilderTool"]
        )
    ],

    dependencies: [
//        .package(url: "https://github.com/elegantchaos/ApplicationExtensions.git", from: "2.1.2"),
//        .package(url: "https://github.com/elegantchaos/BindingsExtensions.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Bundles.git", from: "1.0.8"),
//        .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.2"),
//        .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
//        .package(url: "https://github.com/elegantchaos/Hardware.git", from: "1.0.1"),
//        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.5.5"),
//        .package(url: "https://github.com/elegantchaos/Octoid.git", from: "1.0.4"),
//        .package(url: "https://github.com/elegantchaos/SheetController.git", from: "1.0.2"),
//        .package(url: "https://github.com/elegantchaos/SwiftUIExtensions.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "ActionBuilderCore",
            dependencies: [
//                "ApplicationExtensions",
//                "BindingsExtensions",
                "Bundles",
//                "CollectionExtensions",
//                "DictionaryCoding",
//                "Hardware",
//                "Logger",
//                "Keychain",
//                "Octoid",
//                "SheetController",
//                "SwiftUIExtensions"
            ]
        ),

        .target(
            name: "ActionBuilderUI",
            dependencies: [
//                "ApplicationExtensions",
//                "BindingsExtensions",
//                "Bundles",
//                "CollectionExtensions",
//                "DictionaryCoding",
//                "Hardware",
//                "Logger",
//                "Keychain",
//                "Octoid",
//                "SheetController",
//                "SwiftUIExtensions"
            ]
        ),

        .executableTarget(
            name: "ActionBuilderTool",
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
