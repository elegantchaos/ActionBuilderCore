// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

struct ToolsVersion: Codable {
    let _version: String
}

struct PlatformInfo: Codable {
    let platformName: String
    let version: String
}

struct PackageInfo: Codable {
    let toolsVersion: ToolsVersion
    let platforms: [PlatformInfo]
}

enum SettingsError: Error {
    case parsingFailed
    case corruptData
}

extension Settings {
    init(forPackage url: URL) throws {
        let spm = Runner(command: "swift", cwd: url)
        let output = try spm.sync(arguments: ["package", "dump-package"])
        guard output.status == 0 else {
            throw SettingsError.parsingFailed
        }
        
        guard let jsonData = output.stdout.data(using: .utf8) else {
            throw SettingsError.corruptData
        }

        print(output.stdout)

        let decoder = JSONDecoder()
        let info = try decoder.decode(PackageInfo.self, from: jsonData)
        print(info)
        
        var defaults = Self()
        
        for name in info.platforms.map(\.platformName) {
            if let id = Platform.ID(rawValue: name) {
                defaults.platforms.insert(id)
            }
        }
        
        
        self = defaults
    }
}
