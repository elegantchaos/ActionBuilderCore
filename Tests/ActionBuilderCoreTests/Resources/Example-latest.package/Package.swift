// swift-tools-version:6.4

import PackageDescription

let package = Package(
  name: "ExamplePackage",
  products: [
    .library(name: "ExamplePackage", targets: ["ExamplePackage"]),
  ],
  targets: [
    .target(name: "ExamplePackage"),
    .testTarget(name: "ExamplePackageTests", dependencies: ["ExamplePackage"]),
  ]
)
