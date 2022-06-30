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
    
    public static let allCases: [Compiler] = [
        // See https://github.com/actions/virtual-environments for available Xcode versions.
        // See https://swiftly.dev/swift-versions for Xcode/Swift version mapping.
        
        Compiler("swift-50", name: "Swift 5.0", short: "5.0", linux: "swift:5.0", mac: .xcode(version: "11.2.1", image: "macos-10.15")),
        Compiler("swift-51", name: "Swift 5.1", short: "5.1", linux: "swift:5.1", mac: .xcode(version: "11.3.1", image: "macos-10.15")),
        Compiler("swift-52", name: "Swift 5.2", short: "5.2", linux: "swift:5.2.3-bionic", mac: .xcode(version: "11.7", image: "macos-11")),
        Compiler("swift-53", name: "Swift 5.3", short: "5.3", linux: "swift:5.3.3-bionic", mac: .xcode(version: "12.4", image: "macos-11")),
        Compiler("swift-54", name: "Swift 5.4", short: "5.4", linux: "swift:5.4.2-bionic", mac: .xcode(version: "12.5.1", image: "macos-11")),
        Compiler("swift-55", name: "Swift 5.5", short: "5.5", linux: "swift:5.5.3-bionic", mac: .xcode(version: "13.0", image: "macos-11")),
        
        // https://download.swift.org/swift-5.6.1-release/xcode/swift-5.6.1-RELEASE/swift-5.6.1-RELEASE-osx.pkg
        Compiler("swift-56", name: "Swift 5.6", short: "5.6", linux: "swift:5.6.1-bionic", mac: .toolchain(version: "13.2.1", branch: "swift-5.6.1-RELEASE", image: "macos-11")),
        
        // https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2022-03-22-a/swift-DEVELOPMENT-SNAPSHOT-2022-03-22-a-osx.pkg
        Compiler("swift-nightly", name: "Swift Development Nightly", short: "dev", linux: "swiftlang/swift:nightly", mac: .toolchain(version: "13.2.1", branch: "development", image: "macos-11")),
    ]
}
