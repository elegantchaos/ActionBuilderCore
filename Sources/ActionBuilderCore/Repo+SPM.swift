// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SemanticVersion

extension Repo {

  /// Initialise from an SPM package directory
  public init(forPackage url: URL) async throws {

    // try to extract git info
    let gitInfo = try? await GitInfo(from: url)
    let defaultName = (gitInfo?.url ?? url).deletingPathExtension().lastPathComponent
    let defaultOwner = gitInfo?.owner ?? Self.defaultOwner

    // use the settings file at the root of the directory to
    // configure the repo (if it exists)
    let settings = try? Settings(from: Self.settingsURL(forPackage: url))
    var repo = Self(settings: settings, defaultName: defaultName, defaultOwner: defaultOwner)

    // try to parse SPM package info
    let package = try await PackageInfo(from: url)

    // extract platforms from the package if they weren't explicitly specified
    if repo.enabledPlatforms.isEmpty {
      for name in package.platforms.map(\.platformName) {
        if let id = Platform.ID(rawInsensitive: name) {
          repo.platforms.insert(id)
        } else if name.lowercased() == "ubuntu" {
          repo.platforms.insert(.linux)
        }
      }

      // default to macOS if nothing was specified
      if repo.platforms.isEmpty {
        repo.platforms.insert(Platform.ID.macOS)
      }
    }

    // extract compiler versions from the package if they weren't explicitly specified
    if repo.enabledCompilers.isEmpty {
      let version = SemanticVersion(package.toolsVersion._version)
      let swiftVersion = "swift\(version.major)\(version.minor)"
      if let compiler = Compiler.ID(rawValue: swiftVersion) {
        repo.compilers = [compiler, .swiftLatest]
      }
    }

    // if the testMode is auto, use the presence of test targets to set it
    if repo.testMode == .auto {
      repo.testMode = package.hasTestTargets ? .test : .build
    }

    self = repo
  }

  /// The URL of the actionbuilder settings file for a given package directory.
  public static func settingsURL(forPackage url: URL) -> URL {
    return url.appendingPathComponent(".actionbuilder.json")
  }
}
