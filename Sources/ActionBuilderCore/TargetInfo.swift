// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Target kind values returned by `swift package dump-package`.
enum TargetType: String, Codable {
    /// A regular library target.
    case regular
    /// An executable target.
    case executable
    /// A test target.
    case test
    /// A system-library target.
    case system
    /// A binary target.
    case binary
    /// A plugin target.
    case plugin
}

/// Minimal target information decoded from package metadata.
struct TargetInfo: Codable {
    /// Target name.
    let name: String
    /// Target kind.
    let type: TargetType
}
