// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//
//public class TestModel: Model {
//    public let repos: [Repo]
//    
//    public init() {
//        var datastoreRepo = Repo("Datastore", owner: "elegantchaos", workflow: "Swift", state: .passing)
//        datastoreRepo.settings = WorkflowSettings(options: ["macOS", "iOS", "linux", "swift-52", "swift-53", "release", "build", "test", "header"])
//        
//        repos = [
//            Repo("Actions", owner: "elegantchaos", workflow: "Tests", state: .passing),
//            Repo("ActionsKit", owner: "elegantchaos", workflow: "Tests", state: .passing),
//            Repo("ApplicationExtensions", owner: "elegantchaos", workflow: "Tests", state: .failing),
//            Repo("BindingsExtensions", owner: "elegantchaos", workflow: "Tests", state: .passing),
//            Repo("Builder", owner: "elegantchaos", workflow: "Tests", state: .passing),
//            Repo("CollectionExtensions", owner: "elegantchaos", workflow: "Tests", state: .passing),
//            Repo("CommandShell", owner: "elegantchaos", workflow: "Tests", state: .passing),
//            datastoreRepo,
//            Repo("Hardware", owner: "elegantchaos", workflow: "Build", state: .failing),
//            Repo("Logger", owner: "elegantchaos", workflow: "tests", state: .unknown),
//            Repo("ViewExtensions", owner: "elegantchaos", workflow: "Tests", state: .passing),
//        ]
//
//        super.init(repos)
//    }
//    
//    public override func load(fromDefaultsKey key: String) {
//    }
//    
//    public override func save(toDefaultsKey key: String) {
//    }
//}
