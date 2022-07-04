// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Repo {
    /// Initialise from a JSON configuration file.
    public init(forConfig config: ActionStatusConfig?, defaultName: String, defaultOwner: String = Self.defaultOwner) {
        self.owner = config?.owner ?? defaultOwner
        self.name = config?.name ?? defaultName
        self.workflow = config?.workflow ?? Self.defaultWorkflow
        self.platforms = config?.platforms ?? []
        self.compilers = config?.compilers ?? []
        self.configurations = config?.configurations ?? []
        self.test = config?.test ?? Self.defaultTest
        self.firstlast = config?.firstlast ?? Self.defaultFirstLast
        self.uploadLogs = config?.uploadLogs ?? Self.defaultUploadLogs
        self.header = config?.header ?? Self.defaultHeader
        self.postSlackNotification = config?.postSlackNotification ?? Self.defaultPostSlackNotification
    }
}
