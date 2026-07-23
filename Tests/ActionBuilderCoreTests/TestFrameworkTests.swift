// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import ActionBuilderCore

/// Tests source-level test-framework import detection.
struct TestFrameworkTests {
  /// Active imports are detected while commented imports are ignored.
  @Test
  func detectsOnlyActiveImports() {
    let source =
      #"""
      import Testing
      // import XCTest
      /*
       import XCTest
       /* import XCTest */
      */
      let example = """
      import XCTest
      """
      """#

    #expect(TestFramework.detected(in: source) == [.swiftTesting])
  }

  /// Both frameworks are retained when both imports are active.
  @Test
  func detectsMixedFrameworks() {
    let source =
      """
      import XCTest
      import Testing
      """

    #expect(TestFramework.detected(in: source) == [.xctest, .swiftTesting])
  }
}
