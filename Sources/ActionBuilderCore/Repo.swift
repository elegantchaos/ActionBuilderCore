// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Repo: Equatable {
    public static let defaultOwner = "Unknown"
    public static let defaultWorkflow = "Tests"
    public static let defaultTest = true
    public static let defaultFirstLast = true
    public static let defaultPostSlackNotification = false
    public static let defaultUploadLogs = true
    public static let defaultHeader = true
    public static let defaultConfigurations: [Configuration] = [.release]
    
    public let name: String
    public let owner: String
    public let workflow: String
    public var platforms: Set<Platform.ID>
    public var compilers: Set<Compiler.ID>
    public var configurations: Set<Configuration>
    public var test: Bool
    public let firstlast: Bool
    public let postSlackNotification: Bool
    public let uploadLogs: Bool
    public let header: Bool

    /// Initialise explicitly.
    public init(name: String, owner: String, workflow: String = "Tests", platforms: [Platform.ID] = [], compilers: [Compiler.ID] = [], configurations: [Configuration] = Self.defaultConfigurations, test: Bool = Self.defaultTest, firstlast: Bool = Self.defaultFirstLast, postSlackNotification: Bool = Self.defaultPostSlackNotification, upload: Bool = Self.defaultUploadLogs, header: Bool = Self.defaultHeader) {
        self.name = name
        self.owner = owner
        self.workflow = workflow
        self.platforms = Set(platforms)
        self.compilers = Set(compilers)
        self.configurations = Set(configurations)
        self.test = test
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
        self.test = settings?.test ?? Self.defaultTest
        self.firstlast = settings?.firstlast ?? Self.defaultFirstLast
        self.uploadLogs = settings?.uploadLogs ?? Self.defaultUploadLogs
        self.header = settings?.header ?? Self.defaultHeader
        self.postSlackNotification = settings?.postSlackNotification ?? Self.defaultPostSlackNotification
    }

    var enabledPlatforms: [Platform] {
        return Platform.platforms
            .filter { platforms.contains($0.id) }
            .sorted { $0.name < $1.name }
    }

    var enabledCompilers: [Compiler] {
        var enabledIDs = self.compilers
        if enabledIDs.contains(.swiftLatest) {
            enabledIDs.remove(.swiftLatest)
            enabledIDs.insert(.latestRelease)
        }
        
        let sorted = Compiler.compilers
            .filter { enabledIDs.contains($0.id) }
            .sorted { $0.id < $1.id }
        
        return sorted
    }
    
    var enabledConfigs: [Configuration] {
        return Configuration.allCases
            .filter { configurations.contains($0) }
            .sorted { $0.rawValue < $1.rawValue }
    }

    var compilersToTest: [Compiler] {
        let supportedCompilers = enabledCompilers
        if firstlast && (supportedCompilers.count > 0) {
            let first = supportedCompilers.first!
            let last = supportedCompilers.last!
            if first.id != last.id {
                return [first, last]
            } else {
                return [first]
            }
        } else {
            return supportedCompilers
        }
    }

}
