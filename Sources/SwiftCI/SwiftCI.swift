// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftWorkflowBuilder

#if canImport(AppKit)
  import AppKit
#endif

/// Command-line entry point that reads package metadata and writes workflow artifacts.
@main struct SwiftCI {
  /// Usage text printed for an unusable command line.
  static let usage = """
    usage: swift ci generate [<package-path>] [--create-config] [--edit-config] [--reveal-config]

    Generates GitHub Actions workflows for testing the Swift package at <package-path>
    (default: the current directory).
    """

  /// Parses the command line, then runs the requested command.
  static func main() async throws {
    let invocation: Invocation
    do {
      invocation = try Invocation(
        arguments: Array(CommandLine.arguments.dropFirst()),
        currentDirectory: URL.currentDirectory()
      )
    } catch {
      FileHandle.standardError.write(Data("\(error.message)\n\n\(usage)\n".utf8))
      exit(EX_USAGE)
    }

    switch invocation.command {
      case .generate:
        try await generate(for: invocation.packageURL, options: invocation.options)
    }
  }

  /// Builds repository settings, then updates workflow/header files.
  static func generate(for url: URL, options: Set<String>) async throws {
    let repo = try await Repo(forPackage: url)

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
      name: "SwiftWorkflowBuilder",
      version: VersionatorVersion.string,
      link: "https://github.com/elegantchaos/SwiftWorkflowBuilder"
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
    let readmeURL = url.appendingPathComponent("README.md")
    let readme = try String(contentsOf: readmeURL, encoding: .utf8)
    try generator.readme(byUpdatingHeaderIn: readme, for: repo)
      .write(to: readmeURL, atomically: true, encoding: .utf8)
  }

  /// Creates a default `.swift-ci.json` file when one does not exist.
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
