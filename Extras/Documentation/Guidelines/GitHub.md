# GitHub Workflow Guidance

Relevance: include this file when work involves GitHub operations, especially via `gh` CLI (PR creation/editing, issue workflows, CI actions, release flow).

## Why this file exists

This module captures safe and repeatable GitHub CLI usage patterns to prevent shell quoting errors and malformed PR content.

## PR Body Safety

- Do not pass rich Markdown with backticks directly as an inline `--body "..."` argument.
- Prefer `--body-file <path>` for PR creation and editing.
- If using heredocs, use single-quoted delimiters to prevent shell substitution.

## Command Construction Checks

Before running `gh` commands that include user-authored markdown:
- verify the shell command cannot trigger command substitution
- verify expected newlines and markdown formatting are preserved
- prefer deterministic non-interactive commands

## Review and Workflow Hygiene

- Keep PR descriptions factual and scoped to the actual diff.
- Include validation summary and any known gaps.
- Avoid mixing unrelated changes in a single PR when possible.
