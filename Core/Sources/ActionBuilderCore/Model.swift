// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/02/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//
//import DictionaryCoding
//import Logger
//import SwiftUI
//import Hardware
//
//public let modelChannel = Channel("com.elegantchaos.actionstatus.Model")
//
//public enum ActionStatusError: Error {
//    case couldntAccessSecurityScope
//}
//    
//public class Model: ObservableObject {
//    public typealias RepoList = [Repo]
//    
//    internal let store: NSUbiquitousKeyValueStore
//    internal let key: String = "State"
//    internal var items: [UUID:Repo]
//    
//    @Published public var itemIdentifiers: [UUID]
//    @Published public var passing: Int = 0
//    @Published public var failing: Int = 0
//    @Published public var running: Int = 0
//    @Published public var queued: Int = 0
//    @Published public var unreachable: Int = 0
//    @Published public var defaultOwner = ""
//    @Published public var defaultName = ""
//    @Published public var defaultWorkflow = "Tests"
//    @Published public var defaultBranches: [String] = []
//
//    public var combinedState: Repo.State {
//        let state: Repo.State
//        if running > 0 {
//            state = .running
//        } else if queued > 0 {
//            state = .queued
//        } else if failing > 0 {
//            state = .failing
//        } else if passing > 0 {
//            state = .passing
//        } else {
//            state = .unknown
//        }
//        return state
//    }
//    
//    public init(_ repos: [Repo], store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default) {
//        self.store = store
//        
//        var index: [UUID:Repo] = [:]
//        var identifiers: [UUID] = []
//        for repo in repos {
//            let id = repo.id
//            index[id] = repo
//            identifiers.append(id)
//        }
//        
//        self.items = index
//        self.itemIdentifiers = identifiers
//        sortItems()
//        NotificationCenter.default.addObserver(self, selector: #selector(modelChangedExternally), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
//    }
//
//    // MARK: Public
//
//    public func load(fromDefaultsKey key: String) {
//        modelChannel.log("Loading from key \(key)")
//        let decoder = Repo.dictionaryDecoder
//        store.synchronize()
//        if let repoIDs = store.array(forKey: key) as? Array<String> {
//            var loadedRepos: [UUID:Repo] = [:]
//            for repoID in repoIDs {
//                if let dict = store.dictionary(forKey: repoID), let id = UUID(uuidString: repoID) {
//                    do {
//                        let repo = try decoder.decode(Repo.self, from: dict)
//                        loadedRepos[id] = repo
//                    } catch {
//                        modelChannel.log("Failed to restore repo data from \(dict).\n\nError:\(error)")
//                    }
//                }
//            }
//            items = loadedRepos
//            sortItems()
//        }
//        
//        if let key = store.string(forKey: .defaultOwnerKey) ?? UserDefaults.standard.string(forKey: .defaultOwnerKey) {
//            defaultOwner = key
//        }
//    }
//    
//    public func save(toDefaultsKey key: String) {
//        modelChannel.log("Saving to key \(key)")
//        let encoder = DictionaryEncoder()
//        var repoIDs: [String] = []
//        for (id, repo) in items {
//            let repoID = id.uuidString
//            if let dict = try? encoder.encode(repo) as [String:Any] {
//                store.set(dict, forKey: repoID)
//                repoIDs.append(repoID)
//            }
//        }
//        
//        if let oldRepoIDs = store.array(forKey: key) as? Array<String> {
//            let removedIDs = Set(oldRepoIDs).subtracting(Set(repoIDs))
//            for removedID in removedIDs {
//                store.removeObject(forKey: removedID)
//            }
//        }
//        
//        store.set(repoIDs, forKey: key)
//        store.set(defaultOwner, forKey: .defaultOwnerKey)
//    }
//    
//    public func repo(withIdentifier id: UUID) -> Repo? {
//        return items[id]
//    }
//    
//    public func update(repo: Repo, addIfMissing: Bool = true) {
//        let item = items[repo.id]
//        let update: Bool
//        if let existing = item, !repo.identical(to: existing) {
//            update = true
//        } else {
//            update = (item == nil) && addIfMissing
//        }
//        
//        if update {
//            modelChannel.log(items[repo.id] == nil ? "Added \(repo)" : "Updated \(repo)")
//            items[repo.id] = repo
//            sortItems()
//        }
//    }
//    
//    public func remember(url: URL, forDevice device: String, inRepo repo: Repo) {
//        if var repo = items[repo.id] {
//            repo.remember(url: url, forDevice: device)
//            update(repo: repo)
//        }
//    }
//     
//    @discardableResult public func addRepo(viewState: ViewState) -> Repo {
//        let repo = Repo(model: self)
//        items[repo.id] = repo
//        itemIdentifiers.append(repo.id)
//
//        return repo
//    }
//    
//    @discardableResult public func addRepo(name: String, owner: String) -> Repo {
//        let repo = Repo(name, owner: owner, workflow: "Tests")
//        items[repo.id] = repo
//        itemIdentifiers.append(repo.id)
//
//        return repo
//    }
//    
//    public func add(fromFolders urls: [URL]) {
//        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
//            let fm = FileManager.default
//            for url in urls {
//                if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: []) {
//                    while let url = enumerator.nextObject() as? URL {
//                        if url.lastPathComponent == ".git" {
//                            add(fromGitRepo: url, detector: detector)
//                        }
//                    }
//                }
//            }
//            sortItems()
//        }
//    }
//    
//    public func remove(atOffsets offsets: IndexSet) {
//        let ids = offsets.map({ self.itemIdentifiers[$0] })
//        remove(repos: ids)
//    }
//    
//    public func remove(repos: [UUID]) {
//        for repoID in repos {
//            items[repoID] = nil
//        }
//        sortItems()
//    }
//}
//
//// MARK: Internal
//
//internal extension Model {
//    
//    @objc func modelChangedExternally() {
//        load(fromDefaultsKey: key)
//    }
//        
//    func sortItems() {
//        let sorted = items.values.sorted { (r1, r2) -> Bool in
//            if (r1.state == r2.state) {
//                return r1.name < r2.name
//            }
//            
//            return r1.state.rawValue > r2.state.rawValue
//        }
//        
//        let set = NSCountedSet()
//        sorted.forEach({ set.add($0.state) })
//
//        passing = set.count(for: Repo.State.passing)
//        failing = set.count(for: Repo.State.failing)
//        running = set.count(for: Repo.State.running)
//        queued = set.count(for: Repo.State.queued)
//        unreachable = set.count(for: Repo.State.unknown)
//        
//        itemIdentifiers = sorted.map({ $0.id })
//    }
//    
//    func add(fromGitRepo localGitFolderURL: URL, detector: NSDataDetector) {
//        let containerURL = localGitFolderURL.deletingLastPathComponent()
//        let containerName = containerURL.lastPathComponent
//        if let config = try? String(contentsOf: localGitFolderURL.appendingPathComponent("config")) {
//            let tweaked = config.replacingOccurrences(of: "git@github.com:", with: "https://github.com/")
//            let range = NSRange(location: 0, length: tweaked.count)
//            for result in detector.matches(in: tweaked, options: [], range: range) {
//                if let url = result.url, url.scheme == "https", url.host == "github.com" {
//                    let name = url.deletingPathExtension().lastPathComponent
//                    let owner = url.deletingLastPathComponent().lastPathComponent
//                    var repo = items.first(where: { $0.value.name == name && $0.value.owner == owner })?.value
//                    if repo == nil {
//                        repo = addRepo(name: name, owner: owner)
//                    }
//                    
//                    if repo?.name == containerName, let identifier = Device.main.identifier, let repo = repo {
//                        remember(url: containerURL, forDevice: identifier, inRepo: repo)
//                        modelChannel.log("Local path for \(repo.name) on machine \(identifier) is \(localGitFolderURL).")
//                    }
//                }
//            }
//        }
//    }
//    
//}
