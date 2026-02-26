# Testing and Validation

Relevance: include this file for all projects where code changes can be validated by tests, linters, formatters, or build checks.

## Why this file exists

This module defines baseline expectations for proving behavior changes and reporting validation status clearly.

## Baseline Expectations

- Add tests for new behavior and bug fixes where practical.
- Prefer focused unit/integration tests over heavy end-to-end tests unless the risk requires full-stack coverage.
- Follow existing repository testing style unless there is a clear reason to improve it.

## Validation Workflow

1. Run narrow checks closest to the change first.
2. Run broader project checks next.
3. Use the shared `validation-flow` skill (`codex/skills/validation-flow`) for standard validation (`rt validate`).
4. If validation cannot run, report exactly what was not validated and why.

## Test Design Guidance

- Test through stable interfaces where possible.
- Keep tests explicit and readable.
- Extract shared test helpers only when they improve clarity.
- Cover edge cases and failure modes touched by the change.

## Reporting Guidance

When summarizing work:
- list what checks were run
- list what checks were skipped
- call out meaningful residual risk from skipped validation
