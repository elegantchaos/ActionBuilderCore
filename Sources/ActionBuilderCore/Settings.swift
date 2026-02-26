// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Settings for the generation process.
/// Can be read from the `.actionbuilder.json` file in the root of a package directory.
public struct Settings: Codable {
    /// Optional repository name override.
    public var name: String?
    /// Optional repository owner override.
    public var owner: String?
    /// Optional workflow name override.
    public var workflow: String?
    /// Optional platform selection override.
    public var platforms: Set<Platform.ID>?
    /// Optional compiler selection override.
    public var compilers: Set<Compiler.ID>?
    /// Optional build configuration override.
    public var configurations: Set<Configuration>?
    /// Optional test-mode flag (`true` test, `false` build, `nil` auto).
    public let test: Bool?
    /// Optional `firstlast` strategy override.
    public let firstlast: Bool?
    /// Optional Slack notification override.
    public let postSlackNotification: Bool?
    /// Optional log upload override.
    public let uploadLogs: Bool?
    /// Optional README header generation override.
    public let header: Bool?
    
    /// Initialise from a configuration file.
    public init(from url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode(Self.self, from: data)
    }
    
    /// Initializes settings from an existing `Repo` instance.
    public init(from repo: Repo) {
        self.name = repo.name
        self.owner = repo.owner
        self.workflow = repo.workflow
        self.platforms = repo.platforms
        self.compilers = repo.compilers
        self.configurations = repo.configurations
        self.test = repo.testMode.asBool
        self.firstlast = repo.firstlast
        self.uploadLogs = repo.uploadLogs
        self.header = repo.header
        self.postSlackNotification = repo.postSlackNotification
    }
}
