// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public class Option {
    public let id: String
    public let name: String
    
    public init(_ id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    public var label: String { return name }
}

extension Option: Equatable {
    public static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.name == rhs.name
    }
}

