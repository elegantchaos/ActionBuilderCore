// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Settings: Codable, Equatable {
    
    public var options: [String] = []
    
    public init(options: [String] = [], test: Bool = true, firstlast: Bool = true, notify: Bool = false, upload: Bool = true, header: Bool = true) {
        self.options = options
        self.test = test
        self.firstlast = firstlast
        self.notify = notify
        self.upload = upload
        self.header = header
    }
    
    var enabledPlatforms: [Platform] {
        return Platform.allCases.filter { options.contains($0.id) }
    }

    var enabledCompilers: [Compiler] {
        return Compiler.compilers.filter { options.contains($0.id.rawValue) }
    }
    
    var enabledConfigs: [Configuration] {
        return Configuration.allCases.filter { options.contains($0.id) }
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
    
    let test: Bool
    let firstlast: Bool
    let notify: Bool
    let upload: Bool
    let header: Bool
}
