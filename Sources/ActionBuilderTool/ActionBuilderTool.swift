// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionBuilderCore
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

        let generator = Generator(name: "ActionBuilderTool", version: "1.0", link: "https://github.com/elegantchaos/ActionBuilderCore")
        let source = generator.workflow(for: repo)
        let workflowsURL = url.appendingPathComponent(".github/workflows")
        if !FileManager.default.fileExists(atPath: workflowsURL.path) {
            try FileManager.default.createDirectory(at: workflowsURL, withIntermediateDirectories: true)
        }
        let sourceURL = workflowsURL.appendingPathComponent("\(repo.workflow).yml")
        try source.data(using: .utf8)?.write(to: sourceURL)
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
}
