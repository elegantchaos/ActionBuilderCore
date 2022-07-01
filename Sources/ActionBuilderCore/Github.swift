// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/06/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct GitHub {
    public enum Location {
        case repo
        case workflow
        case releases
        case actions
        case badge(String)
    }
        
    public static func githubURL(for repo: Repo, location: Location = .workflow) -> URL {
            let suffix: String
            switch location {
                case .workflow: suffix = "/actions?query=workflow%3A\(repo.workflow)"
                case .releases: suffix = "/releases"
                case .actions: suffix = "/actions"
                case .badge(let branch):
                    let query = branch.isEmpty ? "" : "?branch=\(branch)"
                    suffix = "/workflows/\(repo.workflow)/badge.svg\(query)"
    
                default: suffix = ""
            }
    
        return URL(string: "https://github.com/\(repo.owner)/\(repo.name)\(suffix)")!
        }
}

struct ImageShield {
    
    public enum Location {
        case release
    }
    
    public static func imgSheildURL(for repo: Repo, suffix: String) -> URL {
        return URL(string: "https://img.shields.io/\(suffix)")!
    }
    
    public static func imgShieldURL(for repo: Repo, type: Location) -> URL {
        let suffix: String
        switch type {
            case .release: suffix = "github/v/release/\(repo.owner)/\(repo.name)"
        }
        
        return imgSheildURL(for: repo, suffix: suffix)
    }

    public static func imgShieldURL(for repo: Repo, compiler: Compiler) -> URL {
        return imgSheildURL(for: repo, suffix: "badge/swift-\(compiler.short)-F05138.svg")
    }

    public static func imgShieldURL(for repo: Repo, platforms: [String]) -> URL {
        let platformBadges = platforms.joined(separator: "_")
        return imgSheildURL(for: repo, suffix: "badge/platforms-\(platformBadges)-lightgrey.svg?style=flat")
    }

}
