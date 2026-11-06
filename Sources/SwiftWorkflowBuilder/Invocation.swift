// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A parsed `swift ci` command line.
public struct Invocation: Sendable {
  /// Subcommands the tool understands.
  public enum Command: String, Sendable {
    /// Writes the workflows (and README header) for a package.
    case generate
  }

  /// Subcommand to run.
  public let command: Command
  /// Package directory the command acts on.
  public let packageURL: URL
  /// `--` options, wherever they appeared.
  public let options: Set<String>

  /// Parses the arguments that follow the executable path.
  public init(arguments: [String], currentDirectory: URL) throws(InvocationError) {
    let positional = arguments.filter { !$0.starts(with: "--") }
    guard let name = positional.first else {
      throw .missingCommand
    }
    guard let command = Command(rawValue: name) else {
      throw .unknownCommand(name)
    }

    self.command = command
    self.options = Set(arguments.filter { $0.starts(with: "--") })
    if positional.count > 1 {
      let path = (positional[1] as NSString).expandingTildeInPath
      self.packageURL = URL(filePath: path, directoryHint: .isDirectory, relativeTo: currentDirectory)
        .absoluteURL
        .resolvingSymlinksInPath()
    } else {
      self.packageURL = currentDirectory
    }
  }
}

/// Errors describing an unusable command line.
public enum InvocationError: Error, Equatable, Sendable {
  case missingCommand
  case unknownCommand(String)
}

extension InvocationError {
  /// Explanation shown to the user.
  public var message: String {
    switch self {
      case .missingCommand: "No command given."
      case .unknownCommand(let command): "Unknown command '\(command)'."
    }
  }
}
