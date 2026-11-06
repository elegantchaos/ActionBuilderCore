// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import SwiftWorkflowBuilder

/// Tests insertion and replacement of the generated README header.
struct HeaderTests {
  /// Generator metadata used by all header tests.
  private let generator = Generator(
    name: "Test Generator",
    version: "1.2.3 (456)",
    link: "https://test.com"
  )

  /// Repository whose header is generated.
  private let repo = Repo(name: "testRepo", owner: "testOwner", platforms: [.macOS], compilers: [.swift62])

  /// Body text that follows the header.
  private let body = "# Test Repo\n\nSome text.\n"

  /// The header generated for `repo`, including its closing delimiter.
  private var header: String { generator.header(for: repo).0 }

  /// A README with no header gets one in front of its existing text.
  @Test
  func headerIsInsertedWhenMissing() {
    #expect(generator.readme(byUpdatingHeaderIn: body, for: repo) == header + body)
  }

  /// A header from an earlier run is replaced, not duplicated.
  @Test
  func currentHeaderIsReplaced() {
    let readme = "<!-- stale -->\n<!-- End of Test Generator Header -->\n\n" + body

    #expect(generator.readme(byUpdatingHeaderIn: readme, for: repo) == header + body)
  }

  /// A header written before the tool was renamed is replaced, not duplicated.
  @Test
  func legacyHeaderIsReplaced() {
    let readme = "<!-- stale -->\n<!-- End of ActionBuilderTool Header -->\n\n" + body

    #expect(generator.readme(byUpdatingHeaderIn: readme, for: repo) == header + body)
  }
}
