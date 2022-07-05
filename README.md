# ActionBuilderCore

Swift code that can take a Swift package, and create a Github Action workflow for it.

The workflow will build and test the package using Github Actions.

## Configuration

The exact steps that the workflow executes can be configured.

These include: 

- platforms to test, from: macOS, iOS, tvOS, watchOS, linux
- swift versions to test against, from: 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, and the nightly build
- the configuration to test: debug, release
- whether to run tests or just build
- whether to upload build logs
- whether to post a notification to a slack channel
- whether to ammend a header to the README
- whether to test against every requested swift version, or just the earliest and latest 

These settings are read from an `.actionbuilder.json` file in the root of the package directory. If it is missing, some defaults are chosen.

If they aren't explicitly set in the configuration file, the code attempts to pick sensible values by examining the `Package.swift` file. The tool version of the file is used to determine the version of Swift to test against. The platforms listed in the file are used to determine platforms to test against.



