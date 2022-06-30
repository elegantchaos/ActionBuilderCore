// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Compiler: Option {
    public enum XcodeMode {
        case xcode(version: String, image: String = "macos-latest")
        case toolchain(version: String, branch: String, image: String = "macos-latest")
    }
    
    let short: String
    let linux: String
    let mac: XcodeMode
    
    public init(_ id: String, name: String, short: String, linux: String, mac: XcodeMode) {
        self.short = short
        self.linux = linux
        self.mac = mac
        super.init(id, name: name)
    }
    
    func supportsTesting(on device: String) -> Bool {
        // no Xcode version supports watchOS testing
        if device == "watchOS" {
            return false
        }

        // macOS toolchain builds can't support testing on iOS/tvOS as they don't include the simulator
        if device != "macOS", case .toolchain = mac {
            return false
        }
        
        return true
    }
}
