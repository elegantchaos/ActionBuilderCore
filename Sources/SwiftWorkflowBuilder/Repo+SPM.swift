// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SemanticVersion

/// Repository construction helpers backed by Swift Package manifest metadata.
extension Repo {

  /// Initialise from an SPM package directory
  public init(forPackage url: URL) async throws {

    // Try to extract git metadata first so defaults match the remote repository.
    let gitInfo = try? await GitInfo(from: url)
    let defaultName = (gitInfo?.url ?? url).deletingPathExtension().lastPathComponent
    let defaultOwner = gitInfo?.owner ?? Self.defaultOwner

    // Use explicit local settings when present.
    let settings = try? Settings(from: Self.settingsURL(forPackage: url))
    var repo = Self(settings: settings, defaultName: defaultName, defaultOwner: defaultOwner)

    // Parse package metadata from `swift package dump-package`.
    let package = try await PackageInfo(from: url)

    // Derive platforms only when no explicit platform settings were provided.
    if repo.enabledPlatforms.isEmpty {
      for name in package.platforms.map(\.name) {
        if let id = Platform.ID(rawInsensitive: name) {
          repo.platforms.insert(id)
        } else if name.lowercased() == "ubuntu" {
          repo.platforms.insert(.linux)
        }
      }

      // Default to macOS if no supported platforms were found in the manifest.
      if repo.platforms.isEmpty {
        repo.platforms.insert(Platform.ID.macOS)
      }
    }

    // Derive compilers only when no explicit compiler settings were provided.
    if repo.enabledCompilers.isEmpty {
      repo.compilers = Compiler.ID.derived(fromToolsVersion: package.toolsVersion)
    }

    // Resolve auto test mode from whether test targets exist.
    if repo.testMode == .auto {
      repo.testMode = package.hasTestTargets ? .test : .build
    }
    repo.testFrameworks = package.testFrameworks

    self = repo
  }

  /// Settings filename for a package directory.
  static let settingsFilename = ".swift-ci.json"

  /// Settings filename used before the tool was renamed; still read when it is the only one present.
  static let legacySettingsFilename = ".actionbuilder.json"

  /// The URL of the settings file for a given package directory.
  /// Prefers `.swift-ci.json`, falls back to an existing `.actionbuilder.json`,
  /// and otherwise names `.swift-ci.json` so new settings use the current name.
  public static func settingsURL(forPackage url: URL) -> URL {
    let current = url.appending(path: settingsFilename)
    let legacy = url.appending(path: legacySettingsFilename)
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: current.path), fileManager.fileExists(atPath: legacy.path) {
      return legacy
    }
    return current
  }
}
