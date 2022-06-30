// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

@dynamicMemberLookup public struct WorkflowSettings: Codable, Equatable {
    public var options: [String] = []
    
    public subscript(dynamicMember option: String) -> Bool {
        return options.contains(option)
    }
    
    public init(options: [String] = []) {
        self.options = options
    }
    
    var enabledPlatforms: [Platform] {
        return Platform.allCases.filter { options.contains($0.id) }
    }

    var enabledCompilers: [Compiler] {
        return Compiler.allCases.filter { options.contains($0.id) }
    }
    
    var enabledConfigs: [Configuration] {
        return Configuration.allCases.filter { options.contains($0.id) }
    }


}
