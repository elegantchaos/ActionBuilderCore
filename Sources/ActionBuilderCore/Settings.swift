// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Settings: Codable, Equatable {
    
    public var platforms: [Platform.ID]
    public var compilers: [Compiler.ID]
    public var configurations: [Configuration]
    public let test: Bool
    public let firstlast: Bool
    public let postSlackNotification: Bool
    public let uploadLogs: Bool
    public let header: Bool

    public init(platforms: [Platform.ID] = [], compilers: [Compiler.ID] = [], configurations: [Configuration] = [.release], test: Bool = true, firstlast: Bool = true, notify: Bool = false, upload: Bool = true, header: Bool = true) {
        self.platforms = platforms
        self.compilers = compilers
        self.configurations = configurations
        self.test = test
        self.firstlast = firstlast
        self.postSlackNotification = notify
        self.uploadLogs = upload
        self.header = header
    }
    
    var enabledPlatforms: [Platform] {
        return Platform.platforms.filter { platforms.contains($0.id) }
    }

    var enabledCompilers: [Compiler] {
        return Compiler.compilers.filter { compilers.contains($0.id) }
    }
    
    var enabledConfigs: [Configuration] {
        return Configuration.allCases.filter { configurations.contains($0) }
    }

    var compilersToTest: [Compiler] {
        let supportedCompilers = enabledCompilers
        if firstlast && (supportedCompilers.count > 0) {
            let first = supportedCompilers.first!
            let last = supportedCompilers.last!
            if first.id != last.id {
                return [first, last]
            } else {
                return [first]
            }
        } else {
            return supportedCompilers
        }
    }
    
}
