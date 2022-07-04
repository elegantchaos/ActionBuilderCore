// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SemanticVersion

extension Repo {

    /// Initialise from an SPM package directory
    public init(forPackage url: URL) throws {
        
        // use the settings file at the root of the directory to
        // configure the repo (if it exists)
        let defaultName = url.deletingPathExtension().lastPathComponent
        let settings = try? Settings(from: url.appendingPathComponent(".actionbuilder.json"))
        var repo = Self(settings: settings, defaultName: defaultName)
        
        // try to parse SPM package info
        let package = try PackageInfo(from: url)
        
        // extract platforms from the package if they weren't explicitly specified
        if repo.enabledPlatforms.isEmpty {
            for name in package.platforms.map(\.platformName) {
                if let id = Platform.ID(rawInsensitive: name) {
                    repo.platforms.insert(id)
                }
            }
        }
        
        // extract compiler versions from the package if they weren't explicitly specified
        if repo.enabledCompilers.isEmpty {
            let version = SemanticVersion(package.toolsVersion._version)
            let swiftVersion = "swift\(version.major)\(version.minor)"
            if let compiler = Compiler.ID(rawValue: swiftVersion) {
                repo.compilers.insert(compiler)
            }
        }

        self = repo
    }

}
