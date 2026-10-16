# ROADMAP

Ideas / tasks for later consideration.

## GitHub Action

Move most of the work to a GitHub Action?
The generated workflow becomes much simpler, and invokes the action to do most of the heavy lifting.

## Swift Scripts

Replace the embedded bash scripts with Swift code / command line tools.

Have the workflow fetch and build the tools (probably by cloning this repo), then run them.

The tools would need to compile on all supported platforms, and using the earliest supported Swift version.

Alternatively we could download pre-compiled binaries, but that is likely to cause a maintenance headache.

## Use Matrix

Can we use the GitHub Actions matrix support to make the generated workflows more compact?

## Workflow validation follow-up (2026-10-15)

Logger PR #34 exposed two issues in workflows emitted by ActionBuilderTool
v2.2.4. Logger now carries local corrections in
`.github/workflows/ActionBuilderXcodeJob.yml`; use those changes and
`Extras/Scripts/test-workflow.sh` as the reference when fixing the generator.

- Required Apple platform jobs must fail when package-scheme discovery,
  CoreSimulator discovery, destination listing, platform downloads or simulator
  boot preparation fail. The generated helper currently converts these errors
  to `exit 0` and skips the required build/test step. In particular,
  `xcodebuild -showdestinations` exit 65 must fail the job. Package-scheme
  listing must preserve the `xcodebuild -list` exit status instead of masking it
  in a grep pipeline. Any intentionally optional platform policy should be
  represented explicitly rather than inferred from arbitrary command failure.
- Enumerate Xcode application paths without parsing `ls` output. The generated
  shared Xcode helper currently has two ShellCheck SC2012 findings. Logger
  writes a glob-expanded path list with `printf` and reads its sorted lines with
  `IFS= read -r`, preserving spaces in application names.

Logger's regression script covers scheme success/failure, iOS/tvOS/watchOS
selection, existing/downloaded simulators, already-booted devices, unsupported
platforms, and failures before/after platform downloads and during booting.
Its five setup-failure checks failed against the unmodified generated helper
and pass against the local corrections; actionlint then passes without findings.

Follow-up: implement these behaviors in Generator+WorkflowHelpers.swift, add
generator/output and shell-behavior regression coverage, regenerate EndToEnd
fixtures, and run the repository's required validation. Then regenerate Logger
and remove its local workflow patch notice once the generated output provides
the same guarantees. No generator implementation was changed during the Logger
cleanup. A reminder is scheduled for 2026-10-16 at 09:00 Europe/London.
