# SwiftWorkflowBuilder Rename

- Renamed the package from ActionBuilderCore to SwiftWorkflowBuilder, and the tool from ActionBuilderTool to `swift-ci`. The swift driver runs any `swift-<name>` executable on `PATH` as `swift <name>`, so the tool is invoked as `swift ci generate`, with no SwiftPM plugin involved. Mint installs it like any other executable.
- The naming discussion ruled out forge-neutral names in the end: GitHub vocabulary reflects the project's origin and no other forge is supported. Known overlaps were accepted: Square's Workflow framework, and the Swift project's `swift-ci` bot, which the README now disclaims.
- `generate` is now a required subcommand, parsed by a testable `Invocation` type. A bare `swift ci`, or the old path-first form, prints usage and exits with `EX_USAGE`.
- ActionBuilderPlugin stays on 2.x and is to be retired. The `--called-from-plugin` flag and the isolated SwiftPM scratch path it enabled were removed; `swift ci` execs the tool directly, so there is no nested SwiftPM to deadlock.
- Settings now live in `.swift-ci.json`. An existing `.actionbuilder.json` is still read when it is the only settings file.
- Generated reusable workflows are now `SwiftWorkflowBuilderSwiftJob.yml` and `SwiftWorkflowBuilderXcodeJob.yml`, and the stamp names SwiftWorkflowBuilder. [Decision 0001](../Decisions/0001-stable-endtoend-workflow-stamps.md) was updated for the new fixed stamp name; its rule is unchanged.
- Found while regenerating this repository: README header replacement searched only for a delimiter containing the current tool name, so every downstream README would have gained a second header. The generator now also recognises the ActionBuilderTool delimiter, and header splicing is covered by tests for the first time.
- Badge URLs in generated headers come from the git remote, so this repository's own header still says ActionBuilderCore until the GitHub repository is renamed and the header regenerated.
