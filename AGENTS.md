# AGENTS.md

## Project Specific Rules

- Keep changes minimal and focused; this package generates GitHub Actions YAML and tests assert exact YAML output, so avoid incidental formatting/order changes.
- Prefer edits in `Sources/ActionBuilderCore` and update `Tests/ActionBuilderCoreTests` expectations in the same change when generated workflow text changes.
- Preserve Swift Package Manager compatibility and existing public API surface unless the task explicitly requests API changes.
- For workflow-generation logic, prefer maintained GitHub Actions setup actions over custom shell installation steps when behavior is equivalent.

## Standard Rules

### Methodology

- Prefer red/green TDD when practical; otherwise follow validation guidance in [Testing](Extras/Documentation/Guidelines/Testing.md).
- Always write maintainable, correct code per [Good Code](Extras/Documentation/Guidelines/Good%20Code.md).
- Apply engineering principles from [Principles](Extras/Documentation/Guidelines/Principles.md): KISS, YAGNI, DRY, make illegal states unrepresentable, dependency injection, composition over inheritance, command-query separation, Law of Demeter, structured concurrency, design by contract, and idempotency.

### Scope and Change Strategy

- Prefer the smallest coherent change that solves the requested problem.
- Preserve current architecture/style unless change is requested or clearly necessary.
- Prefer root-cause fixes over layered workarounds.
- Avoid unrelated refactors while doing focused task work.

### Workflow Expectations

1. Understand request boundaries and constraints.
2. Inspect relevant code and docs before editing.
3. Apply a minimal, coherent change set.
4. Add or update tests for behavior changes when feasible.
5. Run relevant validation.
6. Report changes, validation status, and residual risks.

### Swift Rules

- Follow [Swift](Extras/Documentation/Guidelines/Swift.md) for Swift-specific conventions.
- Prefer modern Swift concurrency and explicit ownership boundaries.
- Avoid force unwraps/`try!` except for truly unrecoverable paths.
- Keep visibility narrow and interfaces intentionally small.

### Testing and Validation

- Run targeted checks first, then broader project checks.
- Use `rt validate` (validation-flow skill) for standard repo validation when possible.
- If validation cannot run, report exactly what was skipped and why.

### GitHub and CI

- Follow [GitHub](Extras/Documentation/Guidelines/GitHub.md) for `gh` CLI safety.
- For PR content, use `gh ... --body-file` instead of inline `--body`.
- Keep CI/workflow changes deterministic and pinned where practical.

### Source Quality

- Use primary sources and official docs for technical decisions per [Trusted Sources](Extras/Documentation/Guidelines/Trusted%20Sources.md).
- Resolve conflicting guidance in favor of official documentation and note conflicts.

### Documentation

- Keep docs factual and aligned with behavior.
- Update docs when commands, workflows, or architecture change.
- Keep agent-focused rules compact; put deeper human guidance in `Extras/Documentation/Guidelines`.

### Safety

- Do not run destructive commands without explicit approval.
- Do not add dependencies without clear justification.
- Never expose or commit secrets.
- If unexpected workspace changes appear during work, pause and confirm direction.

---

Regeneration note: Refresh this file periodically from shared guidance using `/Users/sam/.local/share/agents/instructions/COMMON.md` and `/Users/sam/.local/share/agents/codex/skills/agents-refresh/WORKFLOW.md`.
