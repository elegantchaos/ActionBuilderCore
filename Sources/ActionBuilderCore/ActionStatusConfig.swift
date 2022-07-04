// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct ActionStatusConfig: Codable {
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
    
    /// Initialise from a JSON configuration file.
    public init(forConfig url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode(Self.self, from: data)
    }
}
