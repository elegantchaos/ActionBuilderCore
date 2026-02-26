# Agent Guidance Notes

## Managed Guidance Files

- `Extras/Documentation/Guidelines/Principles.md`
- `Extras/Documentation/Guidelines/Testing.md`
- `Extras/Documentation/Guidelines/Trusted Sources.md`
- `Extras/Documentation/Guidelines/Good Code.md`
- `Extras/Documentation/Guidelines/Swift.md`
- `Extras/Documentation/Guidelines/GitHub.md`

## Stack Evidence Used

- Swift package detected via `Package.swift` and `.swift` source files in `Sources/` and `Tests/`.
- GitHub Actions workflow usage detected via `.github/workflows/Tests.yml`.
- CI generation domain detected from project purpose and workflow generator code in `Sources/ActionBuilderCore/Platform.swift`.

## Included Modules

- Baseline: `instructions/COMMON.md`
- Core: `Principles.md`, `Testing.md`, `Trusted Sources.md`, `Good Code.md`
- Language: `languages/Swift.md`
- Service: `services/GitHub.md`

## Excluded Modules

- `languages/JavaScript.md` (no JS/TS stack evidence)
- `languages/Python.md` (no Python stack evidence)
- `technologies/SwiftUI.md` (no SwiftUI/UI app evidence)

## Conflict Check

- No unresolved local-vs-shared conflicts found.
