// swift-tools-version:5.6

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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
        
            .executable(
                name: "ActionBuilderTool",
                targets: [
                    "ActionBuilderTool"
                ]
            ),
        
    ],
    
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner.git", from: "1.3.1"),
        .package(url: "https://github.com/elegantchaos/SemanticVersion.git", from: "1.1.0"),
        .package(url: "https://github.com/elegantchaos/Versionator.git", from: "1.0.2"),
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.4.7")
    ],
    
    targets: [
        .target(
            name: "ActionBuilderCore",
            
            dependencies: [
                "Runner",
                "SemanticVersion"
            ]
        ),
        
            .executableTarget(
                name: "ActionBuilderTool",
                dependencies: [
                    "ActionBuilderCore"
                ],
                plugins: [
                    .plugin(name: "VersionatorPlugin", package: "Versionator")
                ]
            ),
        
            .testTarget(
                name: "ActionBuilderCoreTests",
                
                dependencies: [
                    "ActionBuilderCore",
                    "XCTestExtensions"
                ],
                
                resources: [
                    .copy("Resources/Example-config.package"),
                    .copy("Resources/Example-mac.package"),
                    .copy("Resources/Example-multi.package")
                ]
            ),
    ]
)
