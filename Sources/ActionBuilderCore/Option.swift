// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Simple ID/name option model used by legacy configuration UI code.
public class Option {
    /// Stable option identifier.
    public let id: String
    /// Human-readable option name.
    public let name: String
    
    /// Creates an option with an identifier and display name.
    public init(_ id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    /// Default display label.
    public var label: String { return name }
}

extension Option: Equatable {
    /// Compares options by display name.
    public static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.name == rhs.name
    }
}
