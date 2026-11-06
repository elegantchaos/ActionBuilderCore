# Version-Only Stamp

- A Mint-installed `swift-ci` 3.0.0 stamped generated files with `SwiftWorkflowBuilder 3.0.0 (1)`. Versionator counts commits with `git rev-list --count HEAD`, and Mint builds from a single-commit clone with no option to change that, so every Mint build reported build 1. Mint-built 2.2.5 did the same.
- The stamp now uses `VersionatorVersion.string`, the version alone. For a tagged release the build number told readers nothing the version didn't.
- A fix that would cover every tool built with Versionator remains open: Versionator could detect a shallow clone with `git rev-parse --is-shallow-repository` and leave the build number out there, instead of reporting 1.
