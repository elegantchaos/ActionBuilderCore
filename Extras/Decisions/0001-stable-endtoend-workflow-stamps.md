# 0001: Stable EndToEnd workflow stamps

Status: Accepted

Decision date: 2026-10-01

Recorded: 2026-10-16

## Context

The EndToEnd freshness check regenerates workflows and compares them with the
committed fixtures. The generator's real version comes from the latest git tag,
and its build number changes with commits. Including either value in the
comparison makes unchanged workflow behavior appear stale after a release tag
or a refresh commit.

## Decision

The EndToEnd refresh script replaces the generated tool version and build number
with the fixed artificial stamp `ActionBuilderTool 0.0.0.` in all three EndToEnd
workflows before publishing the fixtures.

Normalization requires a version-bearing stamp. Missing or versionless stamps
remain detectable by the freshness check. Generator tests separately verify
that the configured real version is emitted correctly.

This normalization applies to EndToEnd fixtures. Ordinary generated workflows
retain the real generator metadata.

## Alternatives considered

- Strip only the build number: rejected because release tags still change the
  version and invalidate the fixtures.
- Refresh and commit fixtures after every release tag: rejected because release
  metadata alone should not require a workflow update.

## Consequences

- Release tags and refresh commits do not invalidate otherwise current fixtures.
- Releases require no EndToEnd refresh solely to update generator metadata.
- Generator behavior changes still require regeneration and freshness checks.
- EndToEnd fixtures do not identify the real generator version; version emission
  is verified independently by generator tests.

## Evidence

- Established by commit `d87e0ba8a60035c11224f994e4864c09cf58e748`.
- Implemented in [the refresh script](../Scripts/refresh-endtoend.sh).
- Required by [the project guidance](../../AGENTS.md).
- Version emission is covered by [GeneratorTests](../../Tests/ActionBuilderCoreTests/GeneratorTests.swift).
