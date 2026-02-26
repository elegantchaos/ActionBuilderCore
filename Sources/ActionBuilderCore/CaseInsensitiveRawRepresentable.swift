// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A `RawRepresentable` helper that supports case-insensitive lookup for string raw values.
protocol CaseInsensitiveRawRepresentable: RawRepresentable, CaseIterable where RawValue == String {
    /// Returns a case-insensitive match from `allCases`, or `nil` when no case matches.
    init?(rawInsensitive: String)
}

extension CaseInsensitiveRawRepresentable {
    /// Initializes by matching `rawInsensitive` against each case's `rawValue`.
    init?(rawInsensitive: String) {
        for c in Self.allCases {
            if c.rawValue.localizedCaseInsensitiveCompare(rawInsensitive) == .orderedSame {
                self = c
                return
            }
        }
        
        return nil
    }
}
 
