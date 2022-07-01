// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Configuration {
    let id: String
    let name: String
    
    public static let allCases = [
        Configuration(id: "debug", name: "Debug"),
        Configuration(id: "release", name: "Release")
    ]
    
    public var isRelease: Bool {
        id == "release"
    }
    
    public var xcodeID: String {
        return name
    }
}
