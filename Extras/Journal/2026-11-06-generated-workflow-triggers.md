# Generated Workflow Triggers

- The generated caller workflow used `on: [push, pull_request]`, so every push to a branch with an open PR ran the whole matrix twice. It now triggers on pushes to `main` and on pull requests ([PR 11](https://github.com/elegantchaos/ActionBuilderCore/pull/11)).
- Neither the generator nor `.actionbuilder.json` had trigger or branch configuration, and the generator does not know a repository's default branch: `GitInfo` reads only the remote URL. The branch is the named default `Repo.defaultBranch`. Detecting it, or making it a setting, is an open option if a repository ever uses another default branch.
- No `tags:` filter was added. Nothing in the release flow waits on a tag-triggered test run.
- The nested trigger broke `Extras/Scripts/refresh-endtoend.sh`, which counted every two-space-indented key in the caller as a job. It now counts only keys under `jobs:`.
- This repository's own `Tests.yml` got the trigger as a hand edit, keeping its release stamp. Downstream packages need regenerating after the next release, at least elegantchaos/Commands (which already has the trigger as a hand edit) and elegantchaos/Logger.
- In the Claude Code sandbox, `agt worktree create` (it writes `.vscode/` files) and the refresh script (SwiftPM cannot start its own nested sandbox) both had to run outside the sandbox.
