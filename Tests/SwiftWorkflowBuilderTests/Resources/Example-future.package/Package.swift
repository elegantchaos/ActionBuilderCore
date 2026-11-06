// swift-tools-version:5.11

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
