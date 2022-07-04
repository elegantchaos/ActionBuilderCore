// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Settings for the generation process.
/// Can be read from the `.actionbuilder.json` file in the root of a package directory.
public struct Settings: Codable {
    public var name: String?
    public var owner: String?
    public var workflow: String?
    public var platforms: Set<Platform.ID>?
    public var compilers: Set<Compiler.ID>?
    public var configurations: Set<Configuration>?
    public let test: Bool?
    public let firstlast: Bool?
    public let postSlackNotification: Bool?
    public let uploadLogs: Bool?
    public let header: Bool?
    
    /// Initialise from a configuration file.
    public init(from url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode(Self.self, from: data)
    }
}
