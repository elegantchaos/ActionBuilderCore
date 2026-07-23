# AGENTS.md

## Project Specific Rules

- Generated workflow YAML is formatting- and order-sensitive; avoid incidental output changes and update exact-output expectations in `Tests/ActionBuilderCoreTests` whenever generated workflow text changes.
- Prefer maintained GitHub Actions setup actions over custom shell installation steps when they provide equivalent behavior.
- Keep generated workflow output deterministic and make changes to external action references deliberate.
- Before creating a pull request or GitHub release, run `Extras/Scripts/refresh-endtoend.sh` and include any regenerated EndToEnd workflow changes.

## Standard Rules

- Always write good, modern, idiomatic code.
- Prefer fixing root causes over layered workarounds.
- Keep interfaces explicit and intentionally small.
- Avoid hidden coupling and surprising side effects.
- Write documentation to reflect the current state.
- Apply DRY, single-source-of-truth, KISS, YAGNI, make-illegal-states-unrepresentable, dependency injection, composition over inheritance, command-query separation, Law of Demeter, structured concurrency, design by contract, and idempotency.
- Understand request boundaries and inspect relevant code and documentation before editing.
- Match change scope to the request: keep focused fixes small and coherent; use codebase-wide cleanup for cleanup, review, modernization, or consistency work.
- Use red/green TDD for non-UI code.
- Add or update tests for behavior changes.
- Create previews for UI code.
- Run the narrowest validation that proves the change first, then broaden to relevant project checks.
- Follow the validation workflow and report skipped checks, validation gaps, and residual risks.
- Prefer trusted primary sources for technical decisions.
- Use portable path references in documentation and guidance. Prefer repository-relative paths for repository files and `~/...` paths for shared resources. Avoid machine-specific absolute paths.
- When a required Mint-installed command is unavailable on `PATH`, use `$HOME/.mint/bin/<command>` before treating it as missing.
- Never expose or commit credentials or secrets.
- Do not perform irreversible destructive actions without explicit approval. Reversible tracked-file deletion does not require additional approval beyond the user's request.
- Avoid unrelated refactors during focused tasks, but report needed follow-up work.
- If unexpected workspace changes appear, pause and confirm direction.
- Do not repeatedly advertise routine verification; report it when uncertainty or risk makes it relevant.

## Skills

- Follow the `coding-standards` skill for all coding, review, refactoring, scripting, testing, and source-quality work.
- Use the `swift` skill for Swift language, toolchain, organization, API, error-handling, and state-modeling guidance.
- Use the `swift-testing-pro` skill when writing, reviewing, or improving Swift Testing tests.
- Use the `validation-flow` skill after code changes for the standard targeted-to-comprehensive validation process and reporting.
- Use the `codex-git` skill for git operations.
- Use the `codex-github` skill for pull requests, releases, GitHub Actions inspection, and non-interactive GitHub CLI work.

To refresh this file, use the `refresh` skill.
