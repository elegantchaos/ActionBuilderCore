# Project Specific Rules

- Generated workflow YAML is formatting- and order-sensitive; avoid incidental output changes and update exact-output expectations in `Tests/ActionBuilderCoreTests` whenever generated workflow text changes.
- Prefer maintained GitHub Actions setup actions over custom shell installation steps when they provide equivalent behavior.
- Keep generated workflow output deterministic and make changes to external action references deliberate.
- Before creating a pull request, run `Extras/Scripts/refresh-endtoend.sh` and include any regenerated EndToEnd workflow changes, because the pull request's own CI checks them.
- The generated EndToEnd workflows carry a fixed artificial stamp (`ActionBuilderTool 0.0.0.`) in place of the real version and build number, so tagging a release or committing a refresh does not make them stale and a release needs no refresh. A stamp that is missing or has no version still fails the freshness check.
- Keep a decision log in `Extras/Decisions/`.

# Standard Rules

1. Locate the shared agents content before starting work. Use `~/.local/share/agents/` when available; otherwise obtain it from https://github.com/elegantchaos/Agents.
2. You must read @~/.local/share/agents/COMMON.md before starting work, and follow the instructions in it at all times (use `COMMON.md` from the GitHub copy when the local one is unavailable).
3. Resolve the skill names below from that same content, including skills provided by plugins.
4. For each skill required by the task, read its `SKILL.md` and every reference it marks as required before starting the work, and follow them. Required references are part of the skill's rules, not optional background.
5. Follow the guidelines in all code you write or change, even where the surrounding code does not.
6. Before reporting work complete, check each changed file against the required skills' checklists, and report the result and any exceptions.
7. Report any required guidance you cannot access.

- Follow the `baseline:standards` skill for all coding.
- Use the `baseline:review` skill for reviewing pull requests and completed work.
- Use the `baseline:records` skill for the decision log.
- Use the `baseline:git` skill for git and GitHub operations.
- Use the `swift:language` skill for all Swift code.
- Also use the `swift:testing` skill for Swift Testing work.
- Also use the `swift:concurrency` skill for actor isolation and shared mutable state.
- Use the `swift:validation` skill after code changes for formatting and validation.

To refresh this file, use the `baseline:refresh` skill.
