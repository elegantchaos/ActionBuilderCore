// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Testing

@testable import SwiftWorkflowBuilder

/// Tests parsing of `swift ci` command lines.
struct InvocationTests {
  /// Directory used as the working directory for parsing.
  let currentDirectory = URL(filePath: "/work/Package", directoryHint: .isDirectory)

  /// `generate` without a path targets the current directory.
  @Test
  func generateDefaultsToCurrentDirectory() throws {
    let invocation = try Invocation(arguments: ["generate"], currentDirectory: currentDirectory)

    #expect(invocation.command == .generate)
    #expect(invocation.packageURL == currentDirectory)
    #expect(invocation.options.isEmpty)
  }

  /// `generate` with a path targets that package.
  @Test
  func generateUsesGivenPath() throws {
    let invocation = try Invocation(arguments: ["generate", "/other/Package"], currentDirectory: currentDirectory)

    #expect(invocation.packageURL.path == "/other/Package")
  }

  /// Relative paths resolve against the current directory.
  @Test
  func generateResolvesRelativePath() throws {
    let invocation = try Invocation(arguments: ["generate", "Nested"], currentDirectory: currentDirectory)

    #expect(invocation.packageURL.path == "/work/Package/Nested")
  }

  /// Options are collected wherever they appear.
  @Test
  func optionsAreCollected() throws {
    let invocation = try Invocation(
      arguments: ["--create-config", "generate", "/other/Package", "--edit-config"],
      currentDirectory: currentDirectory
    )

    #expect(invocation.command == .generate)
    #expect(invocation.packageURL.path == "/other/Package")
    #expect(invocation.options == ["--create-config", "--edit-config"])
  }

  /// A bare invocation is a usage error.
  @Test
  func missingCommandIsRejected() {
    #expect(throws: InvocationError.missingCommand) {
      try Invocation(arguments: [], currentDirectory: currentDirectory)
    }
  }

  /// The pre-rename form, which took a path without a command, is a usage error.
  @Test
  func unknownCommandIsRejected() {
    #expect(throws: InvocationError.unknownCommand("/other/Package")) {
      try Invocation(arguments: ["/other/Package"], currentDirectory: currentDirectory)
    }
  }
}
