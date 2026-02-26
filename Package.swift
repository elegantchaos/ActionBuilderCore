// swift-tools-version:6.2

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
  name: "ActionBuilderCore",

  platforms: [
    .macOS(.v26)
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
    .package(url: "https://github.com/elegantchaos/Runner.git", from: "2.1.5"),
    .package(url: "https://github.com/elegantchaos/SemanticVersion.git", from: "1.1.2"),
    .package(url: "https://github.com/elegantchaos/Versionator.git", exact: "2.1.1"),
    .package(url: "https://github.com/elegantchaos/ChaosTesting", from: "1.0.1"),
    .package(url: "https://github.com/elegantchaos/Matchable", from: "1.0.7"),
  ],

  targets: [
    .target(
      name: "ActionBuilderCore",

      dependencies: [
        "Runner",
        "SemanticVersion",
      ]
    ),

    .executableTarget(
      name: "ActionBuilderTool",
      dependencies: [
        "ActionBuilderCore",
      ],
      plugins: [
        .plugin(name: "VersionatorPlugin", package: "Versionator")
      ]
    ),

    .testTarget(
      name: "ActionBuilderCoreTests",

      dependencies: [
        "ActionBuilderCore",
        "ChaosTesting",
        "Matchable",
      ],

      resources: [
        .copy("Resources/Example-config.package"),
        .copy("Resources/Example-mac.package"),
        .copy("Resources/Example-multi.package"),
        .copy("Resources/Example-old.package"),
      ]
    ),
  ]
)
