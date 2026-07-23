// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Describes a supported platform and emits caller jobs for that platform.
public final class Platform: Identifiable, Sendable {
  /// Stable platform identifier used in configuration and job IDs.
  public let id: ID

  /// Human-readable platform name used in job titles.
  public let name: String

  /// Indicates that the platform is built through Xcode and a simulator destination.
  public var needsDestination: Bool {
    switch id {
      case .iOS, .tvOS, .watchOS, .visionOS:
        return true
      case .macOS, .catalyst, .linux:
        return false
    }
  }

  /// Canonical platform identifiers recognized by ActionBuilder.
  public enum ID: String, Codable, CaseInsensitiveRawRepresentable, Sendable {
    /// macOS, built with Swift Package Manager.
    case macOS

    /// iOS, built with Xcode against a simulator.
    case iOS

    /// tvOS, built with Xcode against a simulator.
    case tvOS

    /// watchOS, built with Xcode against a simulator.
    case watchOS

    /// visionOS, built with Xcode against a simulator.
    case visionOS

    /// Mac Catalyst.
    case catalyst

    /// Linux, built with Swift Package Manager.
    case linux
  }

  /// Default platform list used for automatic platform discovery.
  public static let platforms = [
    Platform(.macOS, name: "macOS"),
    Platform(.iOS, name: "iOS"),
    Platform(.tvOS, name: "tvOS"),
    Platform(.watchOS, name: "watchOS"),
    Platform(.visionOS, name: "visionOS"),
    Platform(.linux, name: "Linux"),
  ]

  /// Creates a platform definition.
  public init(_ id: ID, name: String) {
    self.id = id
    self.name = name
  }

  /// Returns the display name used for a workflow job.
  public func jobName(with compiler: Compiler) -> String {
    if needsDestination {
      switch compiler.mac {
        case .xcode(let version, _), .toolchain(let version, _, _):
          let xcodeName =
            compiler.id == .swiftNightly
            ? "Xcode \(version)"
            : "Xcode matching Swift \(compiler.short)"
          return "\(name) (\(compiler.name), \(xcodeName))"
      }
    }

    return "\(name) (\(compiler.name))"
  }

  /// Generates concise caller jobs for this platform and compiler set.
  public func yaml(repo: Repo, compilers: [Compiler]) -> String {
    compilers.map { callerJob(repo: repo, compiler: $0) }.joined()
  }
}

extension Platform {
  /// Operation selected for a reusable workflow invocation.
  fileprivate enum WorkflowOperation: String {
    /// Compile without running tests.
    case build

    /// Compile and run tests.
    case test
  }

  /// Toolchain setup strategy selected for a reusable workflow invocation.
  fileprivate enum SetupMode: String {
    /// Install a released Swift toolchain.
    case release

    /// Install the latest development Swift snapshot.
    case development

    /// Install a versioned Swift snapshot.
    case snapshot

    /// Resolve an installed Xcode matching a released Swift compiler.
    case xcodeRelease = "xcode-release"

    /// Select Xcode and install a separate Swift snapshot toolchain.
    case xcodeToolchain = "xcode-toolchain"
  }

  /// Generates one caller job that delegates to a reusable workflow.
  fileprivate func callerJob(repo: Repo, compiler: Compiler) -> String {
    let operation: WorkflowOperation =
      repo.testMode != .build && (!needsDestination || compiler.supportsTesting(on: id))
      ? .test
      : .build
    let helperPath = needsDestination ? Generator.xcodeJobPath : Generator.swiftJobPath
    let runner = runner(for: compiler)
    let notificationName = "\(name) (\(compiler.name))"

    var yaml =
      """

        \(id)-\(compiler.id):
          name: \(YAML.quoted(jobName(with: compiler)))
          uses: ./\(helperPath)
          with:
      """

    if needsDestination {
      yaml.append(
        """

              package: \(YAML.quoted(repo.name))
              platform: \(YAML.quoted(id.rawValue))
              runner: \(YAML.quoted(runner))
              swift-version: \(YAML.quoted(compiler.short))
              compiler-id: \(YAML.quoted(compiler.id.rawValue))
              preferred-xcode-version: \(YAML.quoted(preferredXcodeVersion(for: compiler)))
              setup-mode: \(YAML.quoted(xcodeSetupMode(for: compiler).rawValue))
              operation: \(YAML.quoted(operation.rawValue))
        """
      )
    } else {
      yaml.append(
        """

              platform: \(YAML.quoted(id.rawValue))
              runner: \(YAML.quoted(runner))
              swift-version: \(YAML.quoted(compiler.short))
              compiler-id: \(YAML.quoted(compiler.id.rawValue))
              setup-mode: \(YAML.quoted(swiftSetupMode(for: compiler).rawValue))
              operation: \(YAML.quoted(operation.rawValue))
        """
      )
    }

    if case .toolchain = compiler.mac {
      yaml.append(
        """

              xcode-version: \(YAML.quoted(xcodeVersion(for: compiler)))
              toolchain-branch: \(YAML.quoted(toolchainBranch(for: compiler)))
        """
      )
    }

    if needsDestination == false, repo.swiftTestPlan == .compilerDependent {
      yaml.append(
        """

              separate-test-methods: \(compiler.supportsSeparateTestMethods)
        """
      )
    }

    if repo.postSlackNotification {
      yaml.append(
        """

            notification-job-name: \(YAML.quoted(notificationName))
          secrets: inherit
        """
      )
    }

    yaml.append("\n")
    return yaml
  }

  /// Returns the runner image used for a compiler on this platform.
  fileprivate func runner(for compiler: Compiler) -> String {
    if id == .linux {
      return compiler.linux.hasPrefix("ubuntu-") ? compiler.linux : "ubuntu-24.04"
    }

    switch compiler.mac {
      case .xcode(_, let image), .toolchain(_, _, let image):
        return image
    }
  }

  /// Returns the reusable Swift workflow setup mode.
  fileprivate func swiftSetupMode(for compiler: Compiler) -> SetupMode {
    if id != .linux, case .toolchain = compiler.mac {
      return .xcodeToolchain
    }

    if compiler.id == .swiftNightly {
      return .development
    }

    if compiler.isSnapshot {
      return .snapshot
    }

    return .release
  }

  /// Returns the reusable Xcode workflow setup mode.
  fileprivate func xcodeSetupMode(for compiler: Compiler) -> SetupMode {
    switch compiler.mac {
      case .xcode:
        return .xcodeRelease
      case .toolchain:
        return .xcodeToolchain
    }
  }

  /// Returns the preferred Xcode major/minor version.
  fileprivate func preferredXcodeVersion(for compiler: Compiler) -> String {
    switch compiler.mac {
      case .xcode(let version, _):
        return version.split(separator: ".").prefix(2).joined(separator: ".")
      case .toolchain:
        return ""
    }
  }

  /// Returns the concrete Xcode version configured for the compiler.
  fileprivate func xcodeVersion(for compiler: Compiler) -> String {
    switch compiler.mac {
      case .xcode(let version, _), .toolchain(let version, _, _):
        return version
    }
  }

  /// Returns the Swift snapshot branch configured for the compiler.
  fileprivate func toolchainBranch(for compiler: Compiler) -> String {
    switch compiler.mac {
      case .xcode:
        return ""
      case .toolchain(_, let branch, _):
        return branch
    }
  }

}
