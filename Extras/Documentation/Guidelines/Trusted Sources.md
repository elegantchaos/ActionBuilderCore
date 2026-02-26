# Trusted Sources for Technical Decisions

Relevance: include this file whenever tasks involve uncertain facts, API behavior, tooling semantics, policy requirements, or external references.

## Why this file exists

This module sets source-quality expectations so technical decisions rely on primary references rather than unverifiable summaries.

## Source Selection Rules

- Prefer official vendor documentation, language specifications, and primary proposals.
- Prefer first-party repositories and official package documentation for dependencies.
- Treat blogs, forum posts, and community summaries as secondary context.
- When sources conflict, defer to official references and note the conflict.

## Recommended Primary Sources

### Apple platforms and APIs

- [developer.apple.com/documentation](https://developer.apple.com/documentation/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Swift language and tooling

- [swift.org documentation](https://www.swift.org/documentation/)
- [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
- [swift-evolution repository](https://github.com/swiftlang/swift-evolution)
- [swift-package-manager repository](https://github.com/swiftlang/swift-package-manager)

### Agent host documentation

- [OpenAI Codex app docs](https://developers.openai.com/codex/app)

## Local and Project Sources

- local project docs in `Extras/Documentation/`
- dependency READMEs and package docs included in the repository

## MCP-Indexed Sources (when available)

Prefer indexed primary docs via MCP tools before broad web search.

## Secondary Sources (verify before relying)

- [Hacking with Swift](https://www.hackingwithswift.com/)
- [Swift Forums](https://forums.swift.org/)
- [Apple Developer Forums](https://developer.apple.com/forums/)

Do not treat secondary sources as final authority for API contracts, language semantics, or policy requirements.

## Trusted Authors

- Martin Fowler
- Kent Beck
- Hunt & Thomas (Pragmatic Programmer)
