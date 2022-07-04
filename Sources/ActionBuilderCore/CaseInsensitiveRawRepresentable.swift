// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol CaseInsensitiveRawRepresentable: RawRepresentable, CaseIterable where RawValue == String {
    init?(rawInsensitive: String)
}

extension CaseInsensitiveRawRepresentable {
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
 
