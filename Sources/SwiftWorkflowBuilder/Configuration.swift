// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Build configurations supported by generated workflows.
public enum Configuration: String, Codable, CaseIterable, Sendable {
  /// Debug configuration.
  case debug
  /// Release configuration.
  case release

  /// Human-readable configuration name used in workflow step titles.
  public var name: String {
    return rawValue.capitalized
  }

  /// Xcode build configuration identifier.
  public var xcodeID: String {
    return rawValue.capitalized
  }
}
