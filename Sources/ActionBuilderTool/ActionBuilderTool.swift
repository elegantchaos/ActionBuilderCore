// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/2022.
//  All code (c) 2022 - present day, Sam Deane.
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

    try updateWorkflow(for: repo, at: url, with: generator)

    if repo.header {
      try updateHeader(for: repo, at: url, with: generator)
    }
  }

  /// Writes the generated workflow YAML into `.github/workflows/<workflow>.yml`.
  static func updateWorkflow(for repo: Repo, at url: URL, with generator: Generator) throws {
    let source = generator.workflow(for: repo)
    let workflowsURL = url.appendingPathComponent(".github/workflows")
    if !FileManager.default.fileExists(atPath: workflowsURL.path) {
      try FileManager.default.createDirectory(at: workflowsURL, withIntermediateDirectories: true)
    }
    let sourceURL = workflowsURL.appendingPathComponent("\(repo.workflow).yml")
    try source.data(using: .utf8)?.write(to: sourceURL)
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
    let data = readme.data(using: .utf8)
    try data?.write(to: readmeURL)
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
