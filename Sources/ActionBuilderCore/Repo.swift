// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Repository-level workflow generation configuration.
public struct Repo: Equatable, Sendable {
  /// Default owner used when git metadata is unavailable.
  public static let defaultOwner = "Unknown"
  /// Default workflow file and display name.
  public static let defaultWorkflow = "Tests"
  /// Default test mode behavior.
  public static let defaultTest = TestMode.auto
  /// Default strategy to run only first and last requested compilers.
  public static let defaultFirstLast = true
  /// Default Slack notification setting.
  public static let defaultPostSlackNotification = false
  /// Default log artifact upload setting.
  public static let defaultUploadLogs = true
  /// Default README header generation setting.
  public static let defaultHeader = true
  /// Default build configurations to run.
  public static let defaultConfigurations: [Configuration] = [.release]

  /// Repository name.
  public let name: String
  /// Repository owner or organization.
  public let owner: String
  /// Workflow display name.
  public let workflow: String
  /// Requested platforms to test.
  public var platforms: Set<Platform.ID>
  /// Requested compiler IDs to test.
  public var compilers: Set<Compiler.ID>
  /// Requested build configurations.
  public var configurations: Set<Configuration>
  /// Test mode for generated jobs.
  public var testMode: TestMode
  /// Frameworks imported by package test targets.
  public var testFrameworks: Set<TestFramework>
  /// Whether to run only earliest and latest selected compiler.
  public let firstlast: Bool
  /// Whether to include Slack notification steps.
  public let postSlackNotification: Bool
  /// Whether to upload `logs/` artifacts.
  public let uploadLogs: Bool
  /// Whether to generate README header content.
  public let header: Bool

  /// Initialise explicitly.
  public init(
    name: String, owner: String, workflow: String = "Tests", platforms: [Platform.ID] = [],
    compilers: [Compiler.ID] = [], configurations: [Configuration] = Self.defaultConfigurations,
    testMode: TestMode = Self.defaultTest, firstlast: Bool = Self.defaultFirstLast,
    testFrameworks: Set<TestFramework> = Set(TestFramework.allCases),
    postSlackNotification: Bool = Self.defaultPostSlackNotification,
    upload: Bool = Self.defaultUploadLogs, header: Bool = Self.defaultHeader
  ) {
    self.name = name
    self.owner = owner
    self.workflow = workflow
    self.platforms = Set(platforms)
    self.compilers = Set(compilers)
    self.configurations = Set(configurations)
    self.testMode = testMode
    self.testFrameworks = testFrameworks
    self.firstlast = firstlast
    self.postSlackNotification = postSlackNotification
    self.uploadLogs = upload
    self.header = header
  }

  /// Initialise from settings
  public init(settings: Settings?, defaultName: String, defaultOwner: String = Self.defaultOwner) {
    self.owner = settings?.owner ?? defaultOwner
    self.name = settings?.name ?? defaultName
    self.workflow = settings?.workflow ?? Self.defaultWorkflow
    self.platforms = settings?.platforms ?? []
    self.compilers = settings?.compilers ?? []
    self.configurations = settings?.configurations ?? Set(Self.defaultConfigurations)
    self.testMode = TestMode(settings?.test)
    self.testFrameworks = Set(TestFramework.allCases)
    self.firstlast = settings?.firstlast ?? Self.defaultFirstLast
    self.uploadLogs = settings?.uploadLogs ?? Self.defaultUploadLogs
    self.header = settings?.header ?? Self.defaultHeader
    self.postSlackNotification =
      settings?.postSlackNotification ?? Self.defaultPostSlackNotification
  }

  /// Platforms requested in settings, resolved to concrete `Platform` values.
  var enabledPlatforms: [Platform] {
    return Platform.platforms
      .filter { platforms.contains($0.id) }
      .sorted { $0.name < $1.name }
  }

  /// Compilers requested in settings, including symbolic and legacy compatibility handling.
  var enabledCompilers: [Compiler] {
    var enabledIDs = self.compilers
    let legacyIDs: Set<Compiler.ID> = [.swift57, .swift58, .swift59]
    if !enabledIDs.isDisjoint(with: legacyIDs) {
      enabledIDs.subtract(legacyIDs)
      enabledIDs.insert(.earliestRelease)
    }

    if enabledIDs.contains(.swiftLatest) {
      enabledIDs.remove(.swiftLatest)
      enabledIDs.insert(.latestRelease)
    }

    let sorted = Compiler.compilers
      .filter { enabledIDs.contains($0.id) }
      .sorted { $0.id < $1.id }

    return sorted
  }

  /// Configurations requested in settings, in stable sorted order.
  var enabledConfigs: [Configuration] {
    return Configuration.allCases
      .filter { configurations.contains($0) }
      .sorted { $0.rawValue < $1.rawValue }
  }

  /// Final compiler list to run, honoring the `firstlast` setting.
  var compilersToTest: [Compiler] {
    let supportedCompilers = enabledCompilers
    guard firstlast, let first = supportedCompilers.first, let last = supportedCompilers.last else {
      return supportedCompilers
    }

    return first.id == last.id ? [first] : [first, last]
  }

  /// Determines which Swift test commands the reusable workflow must contain.
  var swiftTestPlan: SwiftTestPlan {
    guard testMode != .build else {
      return .none
    }

    let separateTestSupport = compilersToTest.map(\.supportsSeparateTestMethods)
    guard testFrameworks.isEmpty == false, separateTestSupport.contains(true) else {
      return .combined
    }

    return separateTestSupport.contains(false) ? .compilerDependent : .filtered
  }

  /// Swift test-command layouts supported by a generated reusable workflow.
  enum SwiftTestPlan {
    /// Do not generate test steps.
    case none

    /// Run the package's tests with one unfiltered command.
    case combined

    /// Generate commands only for the detected frameworks.
    case filtered

    /// Select filtered or combined commands based on compiler capability.
    case compilerDependent
  }

  /// Controls whether jobs only build or also run tests.
  public enum TestMode: Sendable {
    /// Build only.
    case build
    /// Build and test.
    case test
    /// Infer from whether package test targets exist.
    case auto

    /// Initializes test mode from legacy optional boolean settings.
    init(_ shouldTest: Bool?) {
      switch shouldTest {
        case false: self = .build
        case true: self = .test
        default: self = .auto
      }
    }

    /// Converts test mode to the persisted optional boolean representation.
    var asBool: Bool? {
      switch self {
        case .test: return true
        case .build: return false
        case .auto: return nil
      }
    }
  }
}
