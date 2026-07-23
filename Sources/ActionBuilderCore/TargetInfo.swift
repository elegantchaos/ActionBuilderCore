// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Minimal target information decoded from `swift package describe`.
struct TargetInfo: Decodable {
  /// Target name.
  let name: String

  /// Repository-relative target source directory.
  let path: String

  /// Source paths relative to the target directory.
  let sources: [String]

  /// Target kind, such as `library` or `test`.
  let type: String

  /// Indicates whether this is a test target.
  var isTest: Bool {
    type == "test"
  }

  /// Maps the package-description fields used for source inspection.
  private enum CodingKeys: String, CodingKey {
    case name
    case path
    case sources
    case type
  }

  /// Decodes targets whose non-source kinds may omit paths or source lists.
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.path = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
    self.sources = try container.decodeIfPresent([String].self, forKey: .sources) ?? []
    self.type = try container.decode(String.self, forKey: .type)
  }
}
