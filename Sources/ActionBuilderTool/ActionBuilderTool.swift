// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionBuilderCore
import Foundation

#if canImport(AppKit)
import AppKit
#endif

@main struct ActionBuilderTool {
    static func main() throws {
        let all = ProcessInfo.processInfo.arguments
        let args = all.filter({ !$0.starts(with: "--") })
        guard args.count == 2 else {
            fatalError("Usage: \(args[0]) <options> <package>")
        }
        
        let url = URL(fileURLWithPath: args[1])
        let repo = try Repo(forPackage: url)
        
        let options = Set(all.filter({ $0.starts(with: "--") }))
        if options.contains("--create-config") {
            makeSettings(for: repo, at: url)
        }
        
        if options.contains("--reveal-config") {
            revealSettings(for: repo, at: url)
        }
        
        if options.contains("--edit-config") {
            editSettings(for: repo, at: url)
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
    
    static func revealSettings(for repo: Repo, at url: URL) {
        let settingsURL = Repo.settingsURL(forPackage: url)
#if canImport(AppKit)
        NSWorkspace.shared.selectFile(settingsURL.path, inFileViewerRootedAtPath: "")
#endif
    }

    static func editSettings(for repo: Repo, at url: URL) {
        let settingsURL = Repo.settingsURL(forPackage: url)
#if canImport(AppKit)
        NSWorkspace.shared.open(settingsURL)
#endif
    }

}
