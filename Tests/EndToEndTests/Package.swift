// swift-tools-version:6.0

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/05/26.
//  All code (c) 2026 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
  name: "ActionBuilderEndToEnd",

  platforms: [
    .macOS(.v12), .iOS(.v14), .tvOS(.v14), .custom("Ubuntu", versionString: "20.04"),
  ],

  products: [
    .library(
      name: "EndToEnd",
      targets: ["EndToEnd"]
    )
  ],

  dependencies: [],

  targets: [
    .target(
      name: "EndToEnd",
      dependencies: []
    ),
    .testTarget(
      name: "EndToEndTests",
      dependencies: ["EndToEnd"]
    ),
  ]
)
