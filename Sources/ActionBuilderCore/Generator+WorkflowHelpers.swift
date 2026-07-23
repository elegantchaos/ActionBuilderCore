// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/07/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

extension Generator {
  /// Generates the reusable Swift Package Manager job workflow.
  func swiftJobWorkflow(for repo: Repo) -> String {
    var source =
      reusableWorkflowHeader()
        + """
        name: ActionBuilder Swift Job

        on:
          workflow_call:
            inputs:
              platform:
                required: true
                type: string
              runner:
                required: true
                type: string
              swift-version:
                required: true
                type: string
              compiler-id:
                required: true
                type: string
              setup-mode:
                required: true
                type: string
              xcode-version:
                required: false
                type: string
                default: ""
              toolchain-branch:
                required: false
                type: string
                default: ""
              operation:
                required: true
                type: string
              separate-test-methods:
                required: false
                type: boolean
                default: true
              upload-logs:
                required: false
                type: boolean
                default: true
              post-slack:
                required: false
                type: boolean
                default: false
              notification-job-name:
                required: false
                type: string
                default: ""
            secrets:
              SLACK_WEBHOOK:
                required: false

        jobs:
          build:
            runs-on: ${{ inputs.runner }}
            steps:
        """

    source.append(commonJobStepsYAML(xcbeautifyCondition: "inputs.platform == 'macOS'"))
    source.append(swiftSelectionStepsYAML())
    source.append(toolchainSetupStepsYAML())
    source.append(
      """

              - name: Swift Version
                run: swift --version
      """
    )

    for configuration in repo.enabledConfigs {
      source.append(swiftBuildStepsYAML(configuration: configuration))
    }

    source.append(finalJobStepsYAML())
    return source + "\n"
  }

  /// Generates the reusable simulator-backed Xcode job workflow.
  func xcodeJobWorkflow(for repo: Repo) -> String {
    var source =
      reusableWorkflowHeader()
        + """
        name: ActionBuilder Xcode Job

        on:
          workflow_call:
            inputs:
              package:
                required: true
                type: string
              platform:
                required: true
                type: string
              runner:
                required: true
                type: string
              swift-version:
                required: true
                type: string
              compiler-id:
                required: true
                type: string
              preferred-xcode-version:
                required: false
                type: string
                default: ""
              setup-mode:
                required: true
                type: string
              xcode-version:
                required: false
                type: string
                default: ""
              toolchain-branch:
                required: false
                type: string
                default: ""
              operation:
                required: true
                type: string
              upload-logs:
                required: false
                type: boolean
                default: true
              post-slack:
                required: false
                type: boolean
                default: false
              notification-job-name:
                required: false
                type: string
                default: ""
            secrets:
              SLACK_WEBHOOK:
                required: false

        jobs:
          build:
            runs-on: ${{ inputs.runner }}
            steps:
        """

    source.append(commonJobStepsYAML())
    source.append(xcodeSelectionStepsYAML())
    source.append(toolchainSetupStepsYAML())
    source.append(destinationSelectionStepsYAML())

    for configuration in repo.enabledConfigs {
      source.append(xcodeBuildStepsYAML(configuration: configuration))
    }

    source.append(finalJobStepsYAML())
    return source + "\n"
  }
}

extension Generator {
  /// Generates checkout, diagnostics, and optional xcbeautify installation steps.
  fileprivate func commonJobStepsYAML(xcbeautifyCondition: String? = nil) -> String {
    let condition =
      xcbeautifyCondition.map { "\n          if: ${{ \($0) }}" } ?? ""

    return
      """

              - name: Checkout
                uses: actions/checkout@v6
              - name: Make Logs Directory
                run: |
                  LOGS_DIR="${GITHUB_WORKSPACE:-$PWD}/logs"
                  mkdir -p "$LOGS_DIR"
                  if [[ "$PWD/logs" != "$LOGS_DIR" && ! -e logs ]]
                  then
                    ln -s "$LOGS_DIR" logs
                  fi
                  {
                    echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
                    echo "runner=${RUNNER_NAME:-unknown} (${RUNNER_OS:-unknown}/${RUNNER_ARCH:-unknown})"
                    echo "workflow=${GITHUB_WORKFLOW:-unknown}"
                    echo "job=${GITHUB_JOB:-unknown}"
                    echo "run_id=${GITHUB_RUN_ID:-unknown}"
                    echo "ref=${GITHUB_REF:-unknown}"
                    echo "sha=${GITHUB_SHA:-unknown}"
                  } > "$LOGS_DIR/run.log"
              - name: Install xcbeautify\(condition)
                run: |
                  if command -v xcbeautify >/dev/null 2>&1
                  then
                    echo "xcbeautify already installed."
                  elif brew install xcbeautify > logs/install-xcbeautify.log 2>&1
                  then
                    echo "xcbeautify installed."
                  else
                    echo "::error::Failed to install xcbeautify."
                    cat logs/install-xcbeautify.log
                    exit 1
                  fi
      """
  }

  /// Generates Swift setup action steps for release and development toolchains.
  fileprivate func swiftSelectionStepsYAML() -> String {
    """

            - name: Select Swift on Linux
              if: ${{ inputs.setup-mode == 'release' && inputs.platform == 'linux' }}
              uses: elegantchaos/setup-swift@allow-patch
              with:
                swift-version: ${{ inputs.swift-version }}
                skip-verify-signature: true
                allow-patch: true
            - name: Select Swift
              if: ${{ inputs.setup-mode == 'release' && inputs.platform != 'linux' }}
              uses: elegantchaos/setup-swift@allow-patch
              with:
                swift-version: ${{ inputs.swift-version }}
                allow-patch: true
            - name: Select Swift Development Snapshot
              if: ${{ inputs.setup-mode == 'development' }}
              uses: SwiftyLab/setup-swift@v1
              with:
                development: true
            - name: Select Swift Snapshot
              if: ${{ inputs.setup-mode == 'snapshot' }}
              uses: SwiftyLab/setup-swift@v1
              with:
                development: true
                swift-version: ${{ inputs.swift-version }}
    """
  }

  /// Generates Xcode resolution and selection steps for release compilers.
  fileprivate func xcodeSelectionStepsYAML() -> String {
    """

            - name: Resolve Xcode Version
              if: ${{ inputs.setup-mode == 'xcode-release' }}
              id: resolve-xcode
              env:
                REQUESTED_SWIFT: ${{ inputs.swift-version }}
                PREFERRED_XCODE: ${{ inputs.preferred-xcode-version }}
              run: |
                ls -d /Applications/Xcode* > logs/xcode-versions.log
                FOUND_XCODE=""
                while read -r APP
                do
                  DEV_DIR="$APP/Contents/Developer"
                  SWIFT_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcrun swift --version 2>/dev/null | head -n 1 | sed -E 's/.*version ([0-9]+\\.[0-9]+).*/\\1/')
                  XCODE_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcodebuild -version 2>/dev/null | awk '/^Xcode / {print $2; exit}')
                  if [[ "$SWIFT_VERSION" == "$REQUESTED_SWIFT" ]]
                  then
                    FOUND_XCODE="$XCODE_VERSION"
                    if [[ "$APP" == *[Bb][Ee][Tt][Aa]* ]]
                    then
                      FOUND_XCODE="$FOUND_XCODE-beta"
                    fi
                    if [[ "$XCODE_VERSION" == "$PREFERRED_XCODE"* ]]
                    then
                      break
                    fi
                  fi
                done < <(ls -d /Applications/Xcode*.app | sort -Vr)

                if [[ -z "$FOUND_XCODE" ]]
                then
                  echo "::error::No installed Xcode matched Swift $REQUESTED_SWIFT."
                  echo "Detected toolchains:"
                  while read -r APP
                  do
                    DEV_DIR="$APP/Contents/Developer"
                    XCODE_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcodebuild -version 2>/dev/null | awk '/^Xcode / {print $2; exit}')
                    SWIFT_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcrun swift --version 2>/dev/null | head -n 1 | sed -E 's/.*version ([0-9]+\\.[0-9]+).*/\\1/')
                    echo "  Xcode $XCODE_VERSION -> Swift $SWIFT_VERSION"
                  done < <(ls -d /Applications/Xcode*.app | sort -Vr)
                  exit 1
                fi

                echo "version=$FOUND_XCODE" >> "$GITHUB_OUTPUT"
            - name: Select Xcode Version
              if: ${{ inputs.setup-mode == 'xcode-release' }}
              uses: maxim-lobanov/setup-xcode@v1
              with:
                xcode-version: ${{ steps.resolve-xcode.outputs.version }}
            - name: Xcode Version
              if: ${{ inputs.setup-mode == 'xcode-release' }}
              run: |
                xcodebuild -version
                swift --version
    """
  }

  /// Generates shared Xcode selection and Swift snapshot installation steps.
  fileprivate func toolchainSetupStepsYAML() -> String {
    """

            - name: Select Snapshot Xcode Version
              if: ${{ inputs.setup-mode == 'xcode-toolchain' }}
              uses: maxim-lobanov/setup-xcode@v1
              with:
                xcode-version: ${{ inputs.xcode-version }}
            - name: Install Swift Snapshot Toolchain
              if: ${{ inputs.setup-mode == 'xcode-toolchain' }}
              env:
                TOOLCHAIN_BRANCH: ${{ inputs.toolchain-branch }}
              run: |
                wget --quiet "https://download.swift.org/$TOOLCHAIN_BRANCH/xcode/latest-build.yml"
                grep "download:" < latest-build.yml > filtered.yml
                sed -e 's/-osx.pkg//g' filtered.yml > stripped.yml
                sed -e 's/:[^:\\/\\/]/YML="/g;s/$/"/g;s/ *=/=/g' stripped.yml > snapshot.sh
                source snapshot.sh
                echo "Installing toolchain: $downloadYML"
                wget --quiet "https://swift.org/builds/$TOOLCHAIN_BRANCH/xcode/$downloadYML/$downloadYML-osx.pkg"
                sudo installer -pkg "$downloadYML-osx.pkg" -target /
                ln -s "/Library/Developer/Toolchains/$downloadYML.xctoolchain/usr/bin" swift-latest
                echo "$PWD/swift-latest" >> "$GITHUB_PATH"
                echo "TOOLCHAINS=swift" >> "$GITHUB_ENV"
                ls -d /Applications/Xcode* > logs/xcode-versions.log
                swift --version
            - name: Snapshot Xcode Version
              if: ${{ inputs.setup-mode == 'xcode-toolchain' }}
              run: |
                xcodebuild -version
                xcrun swift --version
    """
  }

  /// Generates Swift build and test steps for one configuration.
  fileprivate func swiftBuildStepsYAML(configuration: Configuration) -> String {
    let rawConfiguration = configuration.rawValue
    return [
      loggedSwiftCommandStepYAML(
        name: "Build (\(rawConfiguration))",
        command: "swift build --configuration \(rawConfiguration) --quiet",
        logName: "swift-build-\(rawConfiguration).log",
        successMessage: "Build (\(rawConfiguration)) succeeded.",
        failureMessage: "Build (\(rawConfiguration)) failed."
      ),
      loggedSwiftCommandStepYAML(
        name: "Test (\(rawConfiguration) XCTest)",
        condition: "inputs.operation == 'test' && inputs.separate-test-methods",
        command: "swift test --disable-swift-testing --configuration \(rawConfiguration)",
        logName: "swift-test-xctest-\(rawConfiguration).log",
        successMessage: "Test (\(rawConfiguration) XCTest) succeeded.",
        failureMessage: "Test (\(rawConfiguration) XCTest) failed."
      ),
      loggedSwiftCommandStepYAML(
        name: "Test (\(rawConfiguration) Swift Testing)",
        condition: "inputs.operation == 'test' && inputs.separate-test-methods",
        command: "swift test --disable-xctest --configuration \(rawConfiguration)",
        logName: "swift-test-swift-testing-\(rawConfiguration).log",
        successMessage: "Test (\(rawConfiguration) Swift Testing) succeeded.",
        failureMessage: "Test (\(rawConfiguration) Swift Testing) failed."
      ),
      loggedSwiftCommandStepYAML(
        name: "Test (\(rawConfiguration))",
        condition: "inputs.operation == 'test' && !inputs.separate-test-methods",
        command: "swift test --configuration \(rawConfiguration)",
        logName: "swift-test-\(rawConfiguration).log",
        successMessage: "Test (\(rawConfiguration)) succeeded.",
        failureMessage: "Test (\(rawConfiguration)) failed."
      ),
    ].joined()
  }

  /// Generates one Swift command step with consistent logging and diagnostics.
  fileprivate func loggedSwiftCommandStepYAML(
    name: String,
    condition: String? = nil,
    command: String,
    logName: String,
    successMessage: String,
    failureMessage: String
  ) -> String {
    let conditionYAML = condition.map { "\n          if: ${{ \($0) }}" } ?? ""

    return
      """

              - name: \(name)\(conditionYAML)
                env:
                  PLATFORM: ${{ inputs.platform }}
                run: |
                  LOG="logs/\(logName)"
                  if \(command) >"$LOG" 2>&1
                  then
                    echo "\(successMessage)"
                  else
                    echo "::error::\(failureMessage)"
                    if [[ "$PLATFORM" == "macOS" ]]
                    then
                      cat "$LOG" | xcbeautify --quiet --disable-logging --renderer github-actions || cat "$LOG"
                    else
                      cat "$LOG"
                    fi
                    exit 1
                  fi
      """
  }

  /// Generates workspace discovery and simulator selection steps.
  fileprivate func destinationSelectionStepsYAML() -> String {
    """

            - name: Detect Workspace and Scheme
              env:
                PACKAGE: ${{ inputs.package }}
                PLATFORM: ${{ inputs.platform }}
              run: |
                WORKSPACE="$PACKAGE.xcworkspace"
                if [[ ! -e "$WORKSPACE" ]]
                then
                  WORKSPACE="."
                  GOT_PACKAGE=$(xcodebuild -workspace . -list | (grep "$PACKAGE-Package" || true))
                  if [[ -n "$GOT_PACKAGE" ]]
                  then
                    SCHEME="$PACKAGE-Package"
                  else
                    SCHEME="$PACKAGE"
                  fi
                else
                  SCHEME="$PACKAGE-$PLATFORM"
                fi
                {
                  echo "WORKSPACE=$WORKSPACE"
                  echo "SCHEME=$SCHEME"
                } >> "$GITHUB_ENV"
            - name: Select Simulator Destination
              id: select-destination
              env:
                PLATFORM: ${{ inputs.platform }}
              run: |
                case "$PLATFORM" in
                  iOS)
                    SIMULATOR_PLATFORM="iOS Simulator"
                    DEVICE_PREFIX="iPhone"
                    FAILURE_MESSAGE="No available non-beta iPhone simulator destination found."
                    ;;
                  tvOS)
                    SIMULATOR_PLATFORM="tvOS Simulator"
                    DEVICE_PREFIX="Apple TV"
                    FAILURE_MESSAGE="No available non-beta Apple TV simulator destination found."
                    ;;
                  watchOS)
                    SIMULATOR_PLATFORM="watchOS Simulator"
                    DEVICE_PREFIX="Apple Watch"
                    FAILURE_MESSAGE="No available non-beta Apple Watch simulator destination found."
                    ;;
                  visionOS)
                    SIMULATOR_PLATFORM="visionOS Simulator"
                    DEVICE_PREFIX="Apple Vision"
                    FAILURE_MESSAGE="No available non-beta Apple Vision simulator destination found."
                    ;;
                  *)
                    echo "::error::Unsupported simulator platform: $PLATFORM"
                    exit 1
                    ;;
                esac

                echo "available=false" >> "$GITHUB_OUTPUT"

                mark_destination_unavailable() {
                  local message="$1"
                  local log="${2:-}"
                  echo "::warning::$message"
                  if [[ -n "$log" && -f "$log" ]]
                  then
                    cat "$log"
                  fi
                  {
                    echo "### $PLATFORM simulator unavailable"
                    echo ""
                    echo "$message"
                    echo ""
                    echo "Build/test steps for this job were skipped because the simulator destination could not be prepared."
                  } >> "$GITHUB_STEP_SUMMARY"
                }

                load_best_destination() {
                  local destinations_log="$1"
                  BEST_DESTINATION=$(
                    while IFS= read -r line
                    do
                      [[ "$line" == *"platform:${SIMULATOR_PLATFORM}"* ]] || continue
                      [[ "$line" == *"name:${DEVICE_PREFIX}"* ]] || continue
                      [[ "$line" != *"unavailable"* ]] || continue

                      id=$(printf '%s\\n' "$line" | sed -nE 's/.*id:[[:space:]]*([^,}]+).*/\\1/p' | xargs)
                      os=$(printf '%s\\n' "$line" | sed -nE 's/.*OS:[[:space:]]*([^,}]+).*/\\1/p' | xargs)
                      name=$(printf '%s\\n' "$line" | sed -nE 's/.*name:[[:space:]]*([^,}]+).*/\\1/p' | xargs)
                      [[ -n "$id" && -n "$os" ]] || continue

                      IFS=. read -r major minor patch <<< "$os"
                      printf "%d\\t%d\\t%d\\t%s\\t%s\\t%s\\n" "${major:-0}" "${minor:-0}" "${patch:-0}" "$os" "$id" "$name"
                    done < "$destinations_log" | sort -k1,1nr -k2,2nr -k3,3nr | head -n 1
                  )
                  DESTINATION_OS=$(echo "$BEST_DESTINATION" | awk -F"\\t" '{print $4}' | xargs)
                  DESTINATION_ID=$(echo "$BEST_DESTINATION" | awk -F"\\t" '{print $5}' | xargs)
                  DESTINATION_NAME=$(echo "$BEST_DESTINATION" | awk -F"\\t" '{print $6}' | xargs)
                  [[ -n "$DESTINATION_NAME" && -n "$DESTINATION_OS" ]]
                }

                boot_destination() {
                  local boot_log="logs/boot-$PLATFORM.log"
                  echo "Booting $PLATFORM simulator ${DESTINATION_NAME:-unknown} (OS ${DESTINATION_OS:-unknown}, id=${DESTINATION_ID:-unknown})."
                  xcrun simctl boot "$DESTINATION_ID" >"$boot_log" 2>&1 || true
                  xcrun simctl bootstatus "$DESTINATION_ID" -b >>"$boot_log" 2>&1
                }

                if ! xcrun simctl list > "logs/simctl-list-$PLATFORM.log" 2>&1
                then
                  mark_destination_unavailable "Unable to connect to CoreSimulator while preparing $PLATFORM." "logs/simctl-list-$PLATFORM.log"
                  exit 0
                fi

                DESTINATIONS_LOG="logs/destinations-$PLATFORM.log"
                if ! xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations > "$DESTINATIONS_LOG" 2>&1
                then
                  mark_destination_unavailable "Unable to list $PLATFORM simulator destinations." "$DESTINATIONS_LOG"
                  exit 0
                fi

                if ! load_best_destination "$DESTINATIONS_LOG"
                then
                  echo "No available $PLATFORM simulator destination found. Downloading platform support."
                  if ! xcodebuild -downloadPlatform "$PLATFORM" > "logs/download-$PLATFORM.log" 2>&1
                  then
                    mark_destination_unavailable "Unable to download $PLATFORM platform support." "logs/download-$PLATFORM.log"
                    exit 0
                  fi
                  if ! xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations > "$DESTINATIONS_LOG" 2>&1
                  then
                    mark_destination_unavailable "Unable to list $PLATFORM simulator destinations after downloading platform support." "$DESTINATIONS_LOG"
                    exit 0
                  fi
                  if ! load_best_destination "$DESTINATIONS_LOG"
                  then
                    mark_destination_unavailable "$FAILURE_MESSAGE" "$DESTINATIONS_LOG"
                    exit 0
                  fi
                fi

                echo "Selected $PLATFORM simulator: ${DESTINATION_NAME:-unknown} (OS ${DESTINATION_OS:-unknown}, id=${DESTINATION_ID:-unknown})."
                if ! boot_destination
                then
                  mark_destination_unavailable "Failed to boot $PLATFORM simulator ${DESTINATION_NAME:-unknown} (OS ${DESTINATION_OS:-unknown}, id=${DESTINATION_ID:-unknown})." "logs/boot-$PLATFORM.log"
                  exit 0
                fi

                {
                  echo "available=true"
                  echo "id=$DESTINATION_ID"
                  echo "name=$DESTINATION_NAME"
                  echo "os=$DESTINATION_OS"
                } >> "$GITHUB_OUTPUT"
    """
  }

  /// Generates Xcode build and test steps for one configuration.
  fileprivate func xcodeBuildStepsYAML(configuration: Configuration) -> String {
    let rawConfiguration = configuration.rawValue
    let xcodeConfiguration = configuration.xcodeID
    let extraArguments = configuration == .release ? " ENABLE_TESTABILITY=YES" : ""

    return [
      xcodeCommandStepYAML(
        operation: "test",
        displayName: "Test",
        progressVerb: "Testing",
        command: "xcodebuild test",
        configurationName: configuration.name,
        xcodeConfiguration: xcodeConfiguration,
        rawConfiguration: rawConfiguration,
        extraArguments: extraArguments
      ),
      xcodeCommandStepYAML(
        operation: "build",
        displayName: "Build",
        progressVerb: "Building",
        command: "xcodebuild clean build",
        configurationName: configuration.name,
        xcodeConfiguration: xcodeConfiguration,
        rawConfiguration: rawConfiguration,
        extraArguments: extraArguments
      ),
    ].joined()
  }

  /// Generates one simulator-backed Xcode command step.
  fileprivate func xcodeCommandStepYAML(
    operation: String,
    displayName: String,
    progressVerb: String,
    command: String,
    configurationName: String,
    xcodeConfiguration: String,
    rawConfiguration: String,
    extraArguments: String
  ) -> String {
    """

            - name: \(displayName) (${{ inputs.platform }} \(configurationName))
              if: ${{ inputs.operation == '\(operation)' && steps.select-destination.outputs.available == 'true' }}
              env:
                DESTINATION_ID: ${{ steps.select-destination.outputs.id }}
                DESTINATION_NAME: ${{ steps.select-destination.outputs.name }}
                DESTINATION_OS: ${{ steps.select-destination.outputs.os }}
                PLATFORM: ${{ inputs.platform }}
              run: |
                set -o pipefail
                echo "\(progressVerb) workspace $WORKSPACE scheme $SCHEME on ${DESTINATION_NAME:-unknown} ($PLATFORM ${DESTINATION_OS:-unknown}, id=${DESTINATION_ID:-unknown})."
                \(command) -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "id=$DESTINATION_ID" -configuration \(xcodeConfiguration) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO\(extraArguments) | tee "logs/xcodebuild-$PLATFORM-\(operation)-\(rawConfiguration).log" | xcbeautify --quiet --disable-logging --renderer github-actions
    """
  }

  /// Generates artifact upload and optional Slack notification steps.
  fileprivate func finalJobStepsYAML() -> String {
    """

            - name: Upload Logs
              if: ${{ always() && inputs.upload-logs }}
              uses: actions/upload-artifact@v7
              with:
                name: ${{ inputs.platform }}-${{ inputs.compiler-id }}-logs
                path: logs
            - name: Slack Notification
              if: ${{ always() && inputs.post-slack }}
              uses: elegantchaos/slatify@master
              with:
                type: ${{ job.status }}
                job_name: ${{ inputs.notification-job-name }}
                mention_if: failure
                url: ${{ secrets.SLACK_WEBHOOK }}
    """
  }
}
