// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

/// Some minimal Swift Package Manager package information.
struct PackageInfo: Codable {
  /// Package name from `dump-package`.
  let name: String
  /// Swift tools version declared in the package manifest.
  let toolsVersion: ToolsVersion
  /// Platforms declared in the package manifest.
  let platforms: [PlatformInfo]
  /// Targets declared in the package manifest.
  let targets: [TargetInfo]

  /// Reads and decodes `swift package dump-package` output.
  init(from url: URL, useIsolatedScratchPath: Bool = false) async throws {
    let scratchPath: URL?
    if useIsolatedScratchPath {
      // Nested SwiftPM invocations (plugin -> tool -> dump-package) can contend on `index.lock`.
      // Using a unique scratch path for the inner invocation avoids that deadlock.
      // In plugin mode this must live inside the package directory, because command
      // plugins are only allowed to write there.
      let path = url
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
    let arguments = if let scratchPath {
      ["package", "--scratch-path", scratchPath.path, "dump-package"]
    } else {
      ["package", "dump-package"]
    }
    let output = spm.run(arguments)
    try await output.throwIfFailed(
      Error.launchingSwiftFailed(url, await output.stderr.string)
    )

    let jsonData = await output.stdout.data
    let decoder = JSONDecoder()
    self = try decoder.decode(PackageInfo.self, from: jsonData)
  }

  /// Returns `true` when at least one target is a test target.
  var hasTestTargets: Bool {
    targets.contains(where: { $0.type == .test })
  }

  /// Minimal tools version wrapper from `dump-package`.
  struct ToolsVersion: Codable {
    let _version: String
  }

  /// Minimal platform information from `dump-package`.
  struct PlatformInfo: Codable {
    let platformName: String
    let version: String
  }

  /// Errors produced while invoking or decoding `swift package dump-package`.
  enum Error: Swift.Error {
    case launchingSwiftFailed(URL, String)
    case corruptData(String)
  }

}
