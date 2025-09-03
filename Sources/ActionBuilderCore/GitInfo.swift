// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

/// Some minimal package information extracted from git.
struct GitInfo: Codable {
  let url: URL
  let owner: String

  init(from url: URL) async throws {
    let spm = Runner(command: "git", cwd: url)
    let output = spm.run(["remote", "-v"])
    try await output.throwIfFailed(Error.launchingGitFailed(url, await output.stderr.string))

    // TODO: recode this using new regex syntax?

    let chunks = await output.stdout.string.split(separator: "\t")
    guard chunks.count > 1 else {
      throw Error.failedGettingRemote(chunks)
    }

    let words = String(chunks[1]).split(separator: " ")
    guard let chunk = words.first else {
      throw Error.failedExtractingRepo(words)
    }

    let repo = String(chunk).replacingOccurrences(
      of: "git@github.com:", with: "https://github.com/")
    guard let url = URL(string: String(repo))
    else {
      throw Error.failedParsingRepo(repo)
    }

    self.url = url
    self.owner = url.deletingLastPathComponent().lastPathComponent
  }

  enum Error: Swift.Error {
    case launchingGitFailed(URL, String)
    case failedGettingRemote([String.SubSequence])
    case failedExtractingRepo([String.SubSequence])
    case failedParsingRepo(String)
  }

}
