// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Settings {
    
    /// Initialise from a JSON configuration file.
    public init(forConfig url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        let config = try decoder.decode(SettingsConfig.self, from: data)
        
        self.platforms = config.platforms ?? []
        self.compilers = config.compilers ?? []
        self.configurations = config.configurations ?? []
        self.test = config.test ?? Self.defaultTest
        self.firstlast = config.firstlast ?? Self.defaultFirstLast
        self.uploadLogs = config.uploadLogs ?? Self.defaultUploadLogs
        self.header = config.header ?? Self.defaultHeader
        self.postSlackNotification = config.postSlackNotification ?? Self.defaultPostSlackNotification
    }
    
    
    struct SettingsConfig: Codable {
        public var platforms: Set<Platform.ID>?
        public var compilers: Set<Compiler.ID>?
        public var configurations: Set<Configuration>?
        public let test: Bool?
        public let firstlast: Bool?
        public let postSlackNotification: Bool?
        public let uploadLogs: Bool?
        public let header: Bool?
    }
}
