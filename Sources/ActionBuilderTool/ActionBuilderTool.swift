// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionBuilderCore
import Foundation

#if canImport(AppKit)
  import AppKit
#endif

/// Command-line entry point that reads package metadata and writes workflow artifacts.
@main struct ActionBuilderTool {
  /// Parses command-line options, builds repository settings, then updates workflow/header files.
  static func main() async throws {
    let all = ProcessInfo.processInfo.arguments
    let args = all.filter({ !$0.starts(with: "--") })
    let options = Set(all.filter({ $0.starts(with: "--") }))

    let url: URL
    if args.count < 2 {
      url = URL.currentDirectory()
    } else {
      let path = (args[1] as NSString).expandingTildeInPath
      url = URL(fileURLWithPath: path, isDirectory: true).resolvingSymlinksInPath()
    }

    let calledFromPlugin = options.contains("--called-from-plugin")
    let repo = try await Repo(forPackage: url, calledFromPlugin: calledFromPlugin)

    if options.contains("--create-config") {
      makeSettings(for: repo, at: url)
    }

    if options.contains("--reveal-config") {
      revealSettings(for: repo, at: url)
    }

    if options.contains("--edit-config") {
      editSettings(for: repo, at: url)
    }

    let generator = Generator(
      name: "ActionBuilderTool",
      version: VersionatorVersion.full,
      link: "https://github.com/elegantchaos/ActionBuilderCore"
    )

    try updateWorkflows(for: repo, at: url, with: generator)

    if repo.header {
      try updateHeader(for: repo, at: url, with: generator)
    }
  }

  /// Writes the generated caller and reusable workflows into `.github/workflows`.
  static func updateWorkflows(for repo: Repo, at url: URL, with generator: Generator) throws {
    for file in generator.workflowFiles(for: repo) {
      let fileURL = url.appending(path: file.relativePath)
      let directoryURL = fileURL.deletingLastPathComponent()
      try FileManager.default.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true
      )
      try file.contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }
  }

  /// Inserts or replaces the generated README header block.
  static func updateHeader(for repo: Repo, at url: URL, with generator: Generator) throws {
    let (header, delimiter) = generator.header(for: repo)

    let readmeURL = url.appendingPathComponent("README.md")
    var readme = try String(contentsOf: readmeURL, encoding: .utf8)
    if let range = readme.range(of: delimiter) {
      readme.removeSubrange(readme.startIndex..<range.upperBound)
    }
    readme.insert(contentsOf: header, at: readme.startIndex)
    try readme.write(to: readmeURL, atomically: true, encoding: .utf8)
  }

  /// Creates a default `.actionbuilder.json` file when one does not exist.
  static func makeSettings(for repo: Repo, at url: URL) {
    let settingsURL = Repo.settingsURL(forPackage: url)
    if !FileManager.default.fileExists(atPath: settingsURL.path) {
      let encoder = JSONEncoder()
      do {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let defaultSettings = try encoder.encode(Settings(from: repo))
        try defaultSettings.write(to: settingsURL)
      } catch {
        print("Failed to create config file.\n\(error)")
      }
    }
  }

  /// Reveals the settings file in Finder when AppKit is available.
  static func revealSettings(for repo: Repo, at url: URL) {
    let settingsURL = Repo.settingsURL(forPackage: url)
    #if canImport(AppKit)
      NSWorkspace.shared.selectFile(settingsURL.path, inFileViewerRootedAtPath: "")
    #endif
  }

  /// Opens the settings file in the default editor when AppKit is available.
  static func editSettings(for repo: Repo, at url: URL) {
    let settingsURL = Repo.settingsURL(forPackage: url)
    #if canImport(AppKit)
      NSWorkspace.shared.open(settingsURL)
    #endif
  }
}
