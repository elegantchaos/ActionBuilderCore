// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import ActionBuilderCore
import Foundation

@main struct ActionBuilderPlugin {
    static func main() throws {
        let args = ProcessInfo.processInfo.arguments
        guard args.count == 2 else {
            fatalError("Usage: \(args[0]) <package>")
        }
                       
        let url = URL(fileURLWithPath: args[1])
        let repo = try Repo(forPackage: url)
        let generator = Generator(name: "ActionBuilderTool", version: "1.0", link: "https://github.com/elegantchaos/ActionBuilderCore")
        let source = generator.workflow(for: repo)
        let sourceURL = url.appendingPathComponent(".github/workflows/\(repo.workflow).yml")
        try source.data(using: .utf8)?.write(to: sourceURL)
    }
}
