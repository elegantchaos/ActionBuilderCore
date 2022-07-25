// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner



/// Some minimal Swift Package Manager package information.
struct PackageInfo: Codable {
    let name: String
    let toolsVersion: ToolsVersion
    let platforms: [PlatformInfo]
    let targets: [TargetInfo]
    
    init(from url: URL) throws {
        let spm = Runner(command: "swift", cwd: url)
        let output = try spm.sync(arguments: ["package", "dump-package"])
        guard output.status == 0 else {
            throw Error.launchingSwiftFailed(url, output.stderr)
        }

        guard let jsonData = output.stdout.data(using: .utf8) else {
            throw Error.corruptData(output.stdout)
        }
        
        let decoder = JSONDecoder()
        self = try decoder.decode(PackageInfo.self, from: jsonData)
    }
    
    var hasTestTargets: Bool {
        targets.contains(where: { $0.type == .test })
    }

    struct ToolsVersion: Codable {
        let _version: String
    }
    
    struct PlatformInfo: Codable {
        let platformName: String
        let version: String
    }
    
    enum Error: Swift.Error {
        case launchingSwiftFailed(URL, String)
        case corruptData(String)
    }

}
