// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public final class Compiler: Identifiable, Sendable {
  public enum XcodeMode: Sendable {
    case xcode(version: String, image: String = "macos-latest")
    case toolchain(version: String, branch: String, image: String = "macos-latest")
  }

  public let id: ID
  let name: String
  let short: String
  let linux: String
  let mac: XcodeMode
  let isSnapshot: Bool

  public init(_ id: ID, name: String, short: String, linux: String, mac: XcodeMode, isSnapshot: Bool = false) {
    self.id = id
    self.name = name
    self.short = short
    self.linux = linux
    self.mac = mac
    self.isSnapshot = isSnapshot
  }

  public var swiftlyName: String {
    if isSnapshot {
      return "\(short)-snapshot"
    } else {
      return short
    }
  }

  func supportsTesting(on platform: Platform.ID) -> Bool {
    // no Xcode version supports watchOS testing
    if platform == .watchOS {
      return false
    }

    // macOS toolchain builds can't support testing on iOS/tvOS as they don't include the simulator
    if platform != .macOS, case .toolchain = mac {
      return false
    }

    return true
  }

  public enum ID: String, Equatable, CaseIterable, Codable, Sendable {
    case swift57
    case swift58
    case swift59
    case swift510
    case swift60
    case swift61
    case swift62

    /// symbolic ID which indicates the latest Swift version.
    case swiftLatest

    /// symbolic ID which indicates the latest Swift nightly build.
    case swiftNightly

    /// Actual ID of the earliest release we support.
    static let earliestRelease = Self.swift57

    /// Actual ID of the latest release we know about.
    static let latestRelease = Self.swift62
  }

  /// All supported compilers, in order from oldest to newest.
  public static let compilers: [Compiler] = [
    // See https://github.com/actions/runner-images for available Xcode versions.
    // See https://xcodereleases.com/ for Xcode/Swift version mapping.

    Compiler(
      .swift57, name: "Swift 5.7", short: "5.7", linux: "swiftlang/swift:nightly-5.7-bionic",
      mac: .xcode(version: "14.2", image: "macos-13")),

    Compiler(
      .swift58, name: "Swift 5.8", short: "5.8", linux: "swiftlang/swift:nightly-5.8-bionic",
      mac: .xcode(version: "14.3.1", image: "macos-13")),

    Compiler(
      .swift59, name: "Swift 5.9", short: "5.9", linux: "swiftlang/swift:nightly-5.9-bionic",
      mac: .xcode(version: "15.2", image: "macos-13")),


    Compiler(
      .swift510, name: "Swift 5.10", short: "5.10", linux: "swiftlang/swift:nightly-5.10-bionic",
      mac: .xcode(version: "15.4", image: "macos-14")),

    Compiler(
      .swift60, name: "Swift 6.0", short: "6.0", linux: "ubuntu-22.04",
      mac: .xcode(version: "16.2.0", image: "macos-14")),

    Compiler(
      .swift61, name: "Swift 6.1", short: "6.1", linux: "ubuntu-22.04",
      mac: .xcode(version: "16.4.0", image: "macos-15")),

    Compiler(
      .swift62, name: "Swift 6.2", short: "6.2", linux: "ubuntu-22.04",
      mac: .xcode(version: "26.0.0", image: "macos-15"), isSnapshot: true),

    // https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2022-03-22-a/swift-DEVELOPMENT-SNAPSHOT-2022-03-22-a-osx.pkg
    Compiler(
      .swiftNightly, name: "Swift Development Nightly", short: "dev",
      linux: "swiftlang/swift:nightly",
      mac: .toolchain(version: "26.0.0", branch: "development", image: "macos-12")),
  ]
}
