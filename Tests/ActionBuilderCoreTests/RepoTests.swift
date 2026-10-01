// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Testing

@testable import ActionBuilderCore

/// Tests repository configuration inferred from package metadata and settings.
struct RepoTests {
  /// Older tools versions map to the currently supported compiler range.
  @Test
  func oldPackageMapsToSupportedCompilers() async throws {
    let examplePackage = try #require(
      Bundle.module.url(forResource: "Example-old", withExtension: "package"))
    let repo = try await Repo(forPackage: examplePackage)

    #expect(Set(repo.enabledCompilers.map(\.id)) == [.earliestRelease, .latestRelease])
  }

  /// A macOS-only package resolves its platform and supported compilers.
  @Test
  func macPackageResolvesPlatformAndCompilers() async throws {
    let examplePackage = try #require(
      Bundle.module.url(forResource: "Example-mac", withExtension: "package"))
    let repo = try await Repo(forPackage: examplePackage)

    #expect(Set(repo.enabledCompilers.map(\.id)) == [.swift510, .latestRelease])
    #expect(repo.enabledPlatforms.map(\.id) == [.macOS])
  }

  /// Multi-platform package metadata includes Linux and Apple platforms.
  @Test
  func multiPlatformPackageResolvesAllPlatforms() async throws {
    let examplePackage = try #require(
      Bundle.module.url(forResource: "Example-multi", withExtension: "package"))
    let repo = try await Repo(forPackage: examplePackage)

    #expect(repo.compilers == [.swift60, .swiftLatest])
    #expect(repo.platforms == [.iOS, .linux, .macOS, .tvOS])
  }

  /// Explicit settings override package-derived defaults.
  @Test
  func configurationFileOverridesDefaults() async throws {
    let examplePackage = try #require(
      Bundle.module.url(forResource: "Example-config", withExtension: "package"))
    let repo = try await Repo(forPackage: examplePackage)

    #expect(repo.name == "ConfigTestPackage")
    #expect(repo.owner == "ConfigTestOwner")
    #expect(repo.compilers == [.swift60, .swiftNightly])
    #expect(repo.platforms == [.macOS, .linux])
    #expect(repo.testMode == .test)
    #expect(repo.header == false)
    #expect(repo.uploadLogs == false)
    #expect(repo.postSlackNotification == false)
    #expect(repo.firstlast == false)
  }

  /// Future tools versions collapse to the latest compiler known by ActionBuilder.
  @Test
  func futureToolsVersionMapsToLatestCompiler() async throws {
    let examplePackage = try #require(
      Bundle.module.url(forResource: "Example-future", withExtension: "package"))
    let repo = try await Repo(forPackage: examplePackage)

    #expect(repo.compilers == [.swiftLatest])
    #expect(Set(repo.enabledCompilers.map(\.id)) == [.latestRelease])
    #expect(repo.testFrameworks == [.swiftTesting])
  }

  /// A package at the newest tools version pins to that exact compiler.
  @Test
  func latestToolsVersionPinsItsCompiler() async throws {
    let examplePackage = try #require(
      Bundle.module.url(forResource: "Example-latest", withExtension: "package"))
    let repo = try await Repo(forPackage: examplePackage)

    #expect(repo.compilers == [.swift64])
    #expect(Compiler.ID.latestRelease == .swift64)
  }

  /// Swift 6.4 builds with Xcode 27.0 on the macOS 26 runner image.
  @Test
  func swift64UsesXcode27OnMacOS26() throws {
    let compiler = try #require(Compiler.compilers.first { $0.id == .swift64 })

    #expect(compiler.name == "Swift 6.4")
    #expect(compiler.short == "6.4")
    guard case .xcode(let version, let image) = compiler.mac else {
      Issue.record("Expected Swift 6.4 to select an Xcode version.")
      return
    }
    #expect(version == "27.0.0")
    #expect(image == "macos-26")
  }

  /// Legacy compiler identifiers collapse to the earliest supported compiler.
  @Test
  func legacyCompilerIdentifiersMapToEarliestCompiler() {
    let repo = Repo(
      name: "testRepo",
      owner: "testOwner",
      platforms: [.macOS],
      compilers: [.swift57, .swift58, .swift59, .swiftLatest],
      firstlast: false
    )

    #expect(Set(repo.enabledCompilers.map(\.id)) == [.earliestRelease, .latestRelease])
  }
}
