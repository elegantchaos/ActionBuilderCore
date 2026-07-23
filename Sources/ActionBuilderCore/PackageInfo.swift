// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

/// Minimal package information decoded from `swift package describe`.
struct PackageInfo: Decodable {
  /// Swift tools version declared in the package manifest.
  let toolsVersion: String

  /// Platforms declared in the package manifest.
  let platforms: [PlatformInfo]

  /// Targets declared in the package manifest.
  let targets: [TargetInfo]

  /// Test frameworks imported by the package's test sources.
  var testFrameworks: Set<TestFramework> = []

  /// Maps the JSON field names emitted by Swift Package Manager.
  private enum CodingKeys: String, CodingKey {
    case toolsVersion = "tools_version"
    case platforms
    case targets
  }

  /// Reads package metadata and detects test-framework imports.
  init(from url: URL, useIsolatedScratchPath: Bool = false) async throws {
    let scratchPath: URL?
    if useIsolatedScratchPath {
      // Nested SwiftPM invocations (plugin -> tool -> dump-package) can contend on `index.lock`.
      // Using a unique scratch path for the inner invocation avoids that deadlock.
      // In plugin mode this must live inside the package directory, because command
      // plugins are only allowed to write there.
      let path =
        url
        .appendingPathComponent(".build", isDirectory: true)
        .appendingPathComponent("actionbuildercore-swiftpm-\(UUID().uuidString)", isDirectory: true)
      try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
      scratchPath = path
    } else {
      scratchPath = nil
    }
    defer {
      if let scratchPath {
        try? FileManager.default.removeItem(at: scratchPath)
      }
    }

    let spm = Runner(command: "swift", cwd: url)
    let arguments =
      if let scratchPath {
        [
          "package", "--disable-sandbox", "--scratch-path", scratchPath.path, "describe", "--type",
          "json",
        ]
      } else {
        ["package", "--disable-sandbox", "describe", "--type", "json"]
      }
    let output = spm.run(arguments)
    try await output.throwIfFailed(
      Error.launchingSwiftFailed(url, await output.stderr.string)
    )

    let jsonData = await output.stdout.data
    let decoder = JSONDecoder()
    var package = try decoder.decode(PackageInfo.self, from: jsonData)
    package.testFrameworks = package.detectTestFrameworks(at: url)
    self = package
  }

  /// Returns `true` when at least one target is a test target.
  var hasTestTargets: Bool {
    targets.contains(where: \.isTest)
  }

  /// Minimal platform information from `swift package describe`.
  struct PlatformInfo: Decodable {
    let name: String
    let version: String
  }

  /// Errors produced while invoking or decoding `swift package dump-package`.
  enum Error: Swift.Error {
    case launchingSwiftFailed(URL, String)
    case corruptData(String)
  }

  /// Detects framework imports in the source files belonging to test targets.
  private func detectTestFrameworks(at packageURL: URL) -> Set<TestFramework> {
    var frameworks: Set<TestFramework> = []

    for target in targets where target.isTest {
      let targetURL = packageURL.appending(path: target.path)
      for sourcePath in target.sources {
        let sourceURL = targetURL.appending(path: sourcePath)
        guard let source = try? String(contentsOf: sourceURL, encoding: .utf8) else {
          continue
        }
        frameworks.formUnion(TestFramework.detected(in: source))
      }
    }

    return frameworks
  }
}
