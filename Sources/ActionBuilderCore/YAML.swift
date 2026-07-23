// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Formatting helpers for dynamic values embedded in generated YAML.
enum YAML {
  /// Quotes and escapes a YAML string value.
  static func quoted(_ value: String) -> String {
    let escaped =
      value
      .replacing("\\", with: "\\\\")
      .replacing("\"", with: "\\\"")
      .replacing("\n", with: "\\n")
      .replacing("\r", with: "\\r")
      .replacing("\t", with: "\\t")
    return "\"\(escaped)\""
  }
}
