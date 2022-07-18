// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionBuilderCore
import AppKit
import Foundation

@main struct ActionBuilderTool {
    static func main() throws {
        let args = ProcessInfo.processInfo.arguments
        guard args.count >= 2 else {
            fatalError("Usage: \(args[0]) <package>")
        }
        
        let url = URL(fileURLWithPath: args[1])
        let repo = try Repo(forPackage: url)
        
        if shouldMakeSettings(arguments: args) {
            makeSettings(for: repo, at: url)
        }
        
        if shouldRevealSettings(arguments: args) {
            revealSettings(for: repo, at: url)
        }
        
        let generator = Generator(name: "ActionBuilderTool", version: "1.0", link: "https://github.com/elegantchaos/ActionBuilderCore")
        try updateWorkflow(for: repo, at: url, with: generator)

        if repo.header {
            try updateHeader(for: repo, at: url, with: generator)
        }
    }
    
    static func updateWorkflow(for repo: Repo, at url: URL, with generator: Generator) throws {
        let source = generator.workflow(for: repo)
        let workflowsURL = url.appendingPathComponent(".github/workflows")
        if !FileManager.default.fileExists(atPath: workflowsURL.path) {
            try FileManager.default.createDirectory(at: workflowsURL, withIntermediateDirectories: true)
        }
        let sourceURL = workflowsURL.appendingPathComponent("\(repo.workflow).yml")
        try source.data(using: .utf8)?.write(to: sourceURL)
    }
    
    static func updateHeader(for repo: Repo, at url: URL, with generator: Generator) throws {
        let (header, delimiter) = generator.header(for: repo)
        
        let readmeURL = url.appendingPathComponent("README.md")
        var readme = try String(contentsOf: readmeURL, encoding: .utf8)
        if let range = readme.range(of: delimiter) {
            readme.removeSubrange(readme.startIndex ..< range.upperBound)
        }
        readme.insert(contentsOf: header, at: readme.startIndex)
        let data = readme.data(using: .utf8)
        try data?.write(to: readmeURL)
    }
    
    static func shouldMakeSettings(arguments: [String]) -> Bool {
        return ProcessInfo.processInfo.arguments.contains("--create-config")
    }
    
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

    static func shouldRevealSettings(arguments: [String]) -> Bool {
        return ProcessInfo.processInfo.arguments.contains("--reveal-config")
    }
    
    static func revealSettings(for repo: Repo, at url: URL) {
        let settingsURL = Repo.settingsURL(forPackage: url)
        print(settingsURL)
        NSWorkspace.shared.selectFile(settingsURL.path, inFileViewerRootedAtPath: "")
    }
}
