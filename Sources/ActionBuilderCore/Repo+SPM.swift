// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SemanticVersion

extension Repo {
    /// Initialise from an SPM package directory
    init(forPackage url: URL) throws {
        
        // try to load config file at the root of the directory
        let configURL = url.appendingPathComponent(".actionbuilder.json")
        let config = try? ActionStatusConfig(forConfig: configURL)

        // default repo settings are based on the config file
        let defaultName = url.deletingPathExtension().lastPathComponent
        var settings = Self(forConfig: config, defaultName: defaultName)
        
        // try to parse package info
        let package = try PackageInfo(from: url)
        
        // extract platforms from the package if they weren't explicitly specified
        if settings.enabledPlatforms.isEmpty {
            for name in package.platforms.map(\.platformName) {
                if let id = Platform.ID(rawInsensitive: name) {
                    settings.platforms.insert(id)
                }
            }
        }
        
        // extract compiler versions from the package if they weren't explicitly specified
        if settings.enabledCompilers.isEmpty {
            let version = SemanticVersion(package.toolsVersion._version)
            let swiftVersion = "swift\(version.major)\(version.minor)"
            if let compiler = Compiler.ID(rawValue: swiftVersion) {
                settings.compilers.insert(compiler)
            }
        }

        self = settings
    }

}
