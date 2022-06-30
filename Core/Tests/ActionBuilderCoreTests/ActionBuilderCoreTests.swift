import XCTest
@testable import ActionBuilderCore

import Bundles

struct MockRepo: RepoDetails {
    let owner = "testOwner"
    let name = "testRepo"
    let workflow = "Tests"
    var settings: ActionBuilderCore.WorkflowSettings

    init(_ options: [String]) {
        settings = WorkflowSettings(options: options)
    }
    
}
final class ActionBuilderCoreTests: XCTestCase {
    func testGenerator() {
        let repo = MockRepo([])
        let generator = WorkflowGenerator()
        
        let output = generator.generateWorkflow(for: repo, application: BundleInfo())
    }
}
