// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// A test framework imported by a package's test sources.
public enum TestFramework: String, CaseIterable, Sendable {
  /// Apple's XCTest framework.
  case xctest

  /// Swift's Testing framework.
  case swiftTesting
}

extension TestFramework {
  /// Lexical state retained while scanning successive source lines.
  private struct LexicalState {
    /// Current nested block-comment depth.
    var blockCommentDepth = 0

    /// Raw-string hash count for the active multiline string, or `nil` when outside one.
    var multilineStringHashCount: Int?
  }

  /// Detects test-framework imports while ignoring line and block comments.
  static func detected(in source: String) -> Set<Self> {
    var frameworks: Set<Self> = []
    var state = LexicalState()

    for line in source.split(separator: "\n", omittingEmptySubsequences: false) {
      let code = importRelevantCode(in: line, state: &state)
      let tokens = code.split(whereSeparator: \.isWhitespace)
      guard
        let importIndex = tokens.firstIndex(of: "import"),
        importIndex + 1 < tokens.endIndex
      else {
        continue
      }

      switch tokens[importIndex + 1] {
        case "XCTest":
          frameworks.insert(.xctest)
        case "Testing":
          frameworks.insert(.swiftTesting)
        default:
          break
      }
    }

    return frameworks
  }

  /// Removes comments and string literals while preserving multiline lexical state.
  private static func importRelevantCode(
    in line: Substring,
    state: inout LexicalState
  ) -> String {
    let characters = Array(line)
    var code = ""
    var index = 0

    while index < characters.count {
      let current = characters[index]
      let next = index + 1 < characters.count ? characters[index + 1] : nil
      let following = index + 2 < characters.count ? characters[index + 2] : nil

      if let hashCount = state.multilineStringHashCount {
        if current == "\"", next == "\"", following == "\"",
          hasHashes(hashCount, after: index + 3, in: characters)
        {
          state.multilineStringHashCount = nil
          index += 3 + hashCount
        } else {
          index += 1
        }
      } else if state.blockCommentDepth > 0 {
        if current == "/", next == "*" {
          state.blockCommentDepth += 1
          index += 2
        } else if current == "*", next == "/" {
          state.blockCommentDepth -= 1
          index += 2
        } else {
          index += 1
        }
      } else if current == "/", next == "/" {
        break
      } else if current == "/", next == "*" {
        state.blockCommentDepth += 1
        index += 2
      } else if let opening = multilineStringOpening(in: characters, startingAt: index) {
        state.multilineStringHashCount = opening.hashCount
        index += opening.length
      } else if current == "\"", next == "\"", following == "\"" {
        state.multilineStringHashCount = 0
        index += 3
      } else if current == "\"" {
        index = indexAfterString(in: characters, startingAt: index)
      } else {
        code.append(current)
        index += 1
      }
    }

    return code
  }

  /// Returns raw-string metadata when a multiline string starts at an index.
  private static func multilineStringOpening(
    in characters: [Character],
    startingAt start: Int
  ) -> (hashCount: Int, length: Int)? {
    guard characters[start] == "#" else {
      return nil
    }

    var quoteIndex = start
    while quoteIndex < characters.count, characters[quoteIndex] == "#" {
      quoteIndex += 1
    }
    let hashCount = quoteIndex - start
    guard
      quoteIndex + 2 < characters.count,
      characters[quoteIndex] == "\"",
      characters[quoteIndex + 1] == "\"",
      characters[quoteIndex + 2] == "\""
    else {
      return nil
    }

    return (hashCount, hashCount + 3)
  }

  /// Checks for an exact number of raw-string hashes after a closing quote sequence.
  private static func hasHashes(
    _ count: Int,
    after start: Int,
    in characters: [Character]
  ) -> Bool {
    guard start + count <= characters.count else {
      return false
    }
    return characters[start..<(start + count)].allSatisfy { $0 == "#" }
  }

  /// Returns the first index after a single-line string literal.
  private static func indexAfterString(in characters: [Character], startingAt start: Int) -> Int {
    var index = start + 1
    var isEscaped = false

    while index < characters.count {
      let character = characters[index]
      if character == "\"", isEscaped == false {
        return index + 1
      }
      if character == "\\", isEscaped == false {
        isEscaped = true
      } else {
        isEscaped = false
      }
      index += 1
    }

    return index
  }
}
