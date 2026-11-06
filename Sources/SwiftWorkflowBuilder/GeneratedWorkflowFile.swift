// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// A generated text file and its path relative to the package root.
public struct GeneratedWorkflowFile: Equatable, Sendable {
  /// Repository-relative destination for the generated file.
  public let relativePath: String

  /// Complete contents to write to `relativePath`.
  public let contents: String

  /// Creates a generated workflow file.
  public init(relativePath: String, contents: String) {
    self.relativePath = relativePath
    self.contents = contents
  }
}
