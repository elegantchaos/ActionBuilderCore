// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Compiler: Identifiable {
    public enum XcodeMode {
        case xcode(version: String, image: String = "macos-latest")
        case toolchain(version: String, branch: String, image: String = "macos-latest")
    }
    
    public let id: Version
    let name: String
    let short: String
    let linux: String
    let mac: XcodeMode
    
    public init(_ id: Version, name: String, short: String, linux: String, mac: XcodeMode) {
        self.id = id
        self.name = name
        self.short = short
        self.linux = linux
        self.mac = mac
    }
    
    func supportsTesting(on platform: Platform.ID) -> Bool {
        // no Xcode version supports watchOS testing
        if platform == .watchOS {
            return false
        }

        // macOS toolchain builds can't support testing on iOS/tvOS as they don't include the simulator
        if platform != .macOS, case .toolchain = mac {
            return false
        }
        
        return true
    }
    
    public enum Version: String, Equatable, CaseIterable {
        case swift50
        case swift51
        case swift52
        case swift53
        case swift54
        case swift55
        case swift56
        case swift57
        case swiftLatest
        case swiftNightly
    }
    
    public static let compilers: [Compiler] = [
        // See https://github.com/actions/virtual-environments for available Xcode versions.
        // See https://swiftly.dev/swift-versions for Xcode/Swift version mapping.
        
        Compiler(.swift50, name: "Swift 5.0", short: "5.0", linux: "swift:5.0", mac: .xcode(version: "11.2.1", image: "macos-10.15")),
        Compiler(.swift51, name: "Swift 5.1", short: "5.1", linux: "swift:5.1", mac: .xcode(version: "11.3.1", image: "macos-10.15")),
        Compiler(.swift52, name: "Swift 5.2", short: "5.2", linux: "swift:5.2.3-bionic", mac: .xcode(version: "11.7", image: "macos-11")),
        Compiler(.swift53, name: "Swift 5.3", short: "5.3", linux: "swift:5.3.3-bionic", mac: .xcode(version: "12.4", image: "macos-11")),
        Compiler(.swift54, name: "Swift 5.4", short: "5.4", linux: "swift:5.4.2-bionic", mac: .xcode(version: "12.5.1", image: "macos-11")),
        Compiler(.swift55, name: "Swift 5.5", short: "5.5", linux: "swift:5.5.3-bionic", mac: .xcode(version: "13.0", image: "macos-11")),
        
        // https://download.swift.org/swift-5.6.1-release/xcode/swift-5.6.1-RELEASE/swift-5.6.1-RELEASE-osx.pkg
        Compiler(.swift56, name: "Swift 5.6", short: "5.6", linux: "swift:5.6.1-bionic", mac: .toolchain(version: "13.2.1", branch: "swift-5.6.1-RELEASE", image: "macos-11")),
        
        // https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2022-03-22-a/swift-DEVELOPMENT-SNAPSHOT-2022-03-22-a-osx.pkg
        Compiler(.swiftNightly, name: "Swift Development Nightly", short: "dev", linux: "swiftlang/swift:nightly", mac: .toolchain(version: "13.2.1", branch: "development", image: "macos-11")),
    ]
}
