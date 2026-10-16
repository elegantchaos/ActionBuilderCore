#!/bin/bash
# Exercises generated Xcode setup steps using mocked tools.
set -euo pipefail

workflow="${1:?Pass the generated Xcode workflow path}"
scratch=$(mktemp -d "${TMPDIR:-/tmp}/workflow-tests.XXXXXX")
trap 'rm -rf "$scratch"' EXIT

# Extracts a named shell step without requiring a YAML dependency.
extract_step() {
  awk -v name="$1" '
  $0 == "        - name: " name { found = 1; next }
  found && /^        - name:/ { exit }
  found && /^          run: / { script = 1; next }
  script { sub(/^            /, ""); print }
  ' "$workflow" > "$2"
  test -s "$2"
}
extract_step 'Select Simulator Destination' "$scratch/select.sh"
extract_step 'Detect Workspace and Scheme' "$scratch/detect.sh"
extract_step 'Resolve Xcode Version' "$scratch/resolve.sh"

# Simulates CoreSimulator discovery and booting, including already-booted devices.
xcrun() {
  local selected_scenario="${SCENARIO:?}"
  [[ "$selected_scenario" != build_* ]] || return 99
  case "$*" in
    'swift --version')
      [[ "$DEVELOPER_DIR" == *'/Xcode 26 Beta.app/Contents/Developer' ]] || return 99
      echo 'Apple Swift version 6.2'
      ;;
    'simctl list')
      [[ "$selected_scenario" != simulator_failure ]]
      ;;
    'simctl boot '*)
      [[ "$selected_scenario" != already_booted ]]
      ;;
    'simctl bootstatus '*)
      [[ "$selected_scenario" != boot_failure ]]
      ;;
    *) return 99 ;;
  esac
}

# Simulates destination discovery and platform downloads without invoking Xcode.
xcodebuild() {
  local selected_scenario="${SCENARIO:?}"
  [[ "$selected_scenario" != build_* ]] || return 99
  local selected_platform="${PLATFORM:?}"
  case "$*" in
    -version)
      [[ "$DEVELOPER_DIR" == *'/Xcode 26 Beta.app/Contents/Developer' ]] || return 99
      echo 'Xcode 26.0'
      ;;
    '-workspace . -list')
      [[ "$selected_scenario" != scheme_failure ]] || return 65
      if [[ "$selected_scenario" == scheme_failure_with_match ]]; then
        echo Logger-Package
        return 65
      fi
      [[ "$selected_scenario" != scheme_fallback ]] || { echo Logger; return; }
      echo Logger-Package
      ;;
    *-showdestinations)
      [[ "$selected_scenario" != discovery_failure ]] || return 65
      case "$selected_scenario" in
        download_failure|no_destination) return 0 ;;
        download_success) [[ -f downloaded ]] || return 0 ;;
        after_download_discovery_failure)
          [[ ! -f downloaded ]] || return 65
          return 0
          ;;
      esac
      case "$selected_platform" in
        iOS) device='iPhone 17' ;;
        tvOS) device='Apple TV' ;;
        watchOS) device='Apple Watch' ;;
        visionOS) device='Apple Vision' ;;
        *) return 99 ;;
      esac
      printf '{ platform:%s Simulator, id:device-123, OS:26.4, name:%s }\n' "$selected_platform" "$device"
      ;;
    -downloadPlatform\ *)
      [[ "$selected_scenario" != download_failure ]] || return 1
      touch downloaded
      ;;
    *) return 99 ;;
  esac
}
export -f xcrun xcodebuild

# Checks one successful or failed setup against the workflow exit status and outputs.
check_selection() {
  local scenario="$1"
  local expected="$2"
  local directory="$scratch/$scenario"
  local platform=iOS
  local operation=test
  local expected_destination=id=device-123
  local actual
  mkdir -p "$directory/logs"
  case "$scenario" in
    build_*) platform="${scenario#build_}"; operation=build; expected_destination="destination=generic/platform=$platform Simulator" ;;
    unsupported_platform) platform=unsupported ;;
    success_tvOS) platform=tvOS ;;
    success_watchOS) platform=watchOS ;;
    success_visionOS) platform=visionOS ;;
  esac

  if (
    cd "$directory"
    SCENARIO="$scenario" PLATFORM="$platform" OPERATION="$operation" WORKSPACE=. SCHEME=Logger-Package \
      GITHUB_OUTPUT="$directory/outputs" GITHUB_STEP_SUMMARY="$directory/summary" \
      bash -e "$scratch/select.sh" > "$directory/run.log" 2>&1
  ); then
    actual=0
  else
    actual=$?
  fi

  if [[ "$expected" == success && "$actual" == 0 ]] &&
    grep -Fxq 'available=true' "$directory/outputs" &&
    grep -Fxq "$expected_destination" "$directory/outputs"; then
    echo "PASS $scenario"
  elif [[ "$expected" == failure && "$actual" != 0 ]] &&
    ! grep -Fxq 'available=true' "$directory/outputs" 2>/dev/null; then
    echo "PASS $scenario"
  else
    echo "FAIL $scenario: expected $expected, exit status $actual"
    cat "$directory/run.log"
    failures=$((failures + 1))
  fi
}

# Checks that scheme discovery propagates tool failure instead of choosing a fallback.
check_schemes() {
  local scenario="$1"
  local expected="$2"
  local directory="$scratch/$scenario"
  local actual
  local expected_scheme=Logger-Package
  [[ "$scenario" != scheme_fallback ]] || expected_scheme=Logger
  mkdir -p "$directory/logs"
  if (
    cd "$directory"
    SCENARIO="$scenario" PACKAGE=Logger PLATFORM=iOS GITHUB_ENV="$directory/environment" \
      bash -e "$scratch/detect.sh" > "$directory/run.log" 2>&1
  ); then
    actual=0
  else
    actual=$?
  fi
  if [[ "$expected" == success && "$actual" == 0 ]] &&
    grep -Fxq "SCHEME=$expected_scheme" "$directory/environment"; then
    echo "PASS $scenario"
  elif [[ "$expected" == failure && "$actual" != 0 ]]; then
    echo "PASS $scenario"
  else
    echo "FAIL $scenario: expected $expected, exit status $actual"
    cat "$directory/run.log"
    failures=$((failures + 1))
  fi
}

# Runs Xcode resolution with an isolated application directory containing spaces.
check_xcode_paths() {
  local directory="$scratch/xcode_paths"
  mkdir -p "$directory/logs" "$directory/Applications/Xcode 26 Beta.app"
  sed "s|/Applications/|$directory/Applications/|g" "$scratch/resolve.sh" > "$directory/resolve.sh"
  if (
    cd "$directory"
    SCENARIO=xcode_paths PLATFORM=iOS REQUESTED_SWIFT=6.2 PREFERRED_XCODE=26 \
      GITHUB_OUTPUT="$directory/outputs" bash -eo pipefail resolve.sh > run.log 2>&1
  ) && grep -Fxq 'version=26.0-beta' "$directory/outputs" &&
    grep -Fxq "$directory/Applications/Xcode 26 Beta.app" "$directory/logs/xcode-versions.log"; then
    echo 'PASS xcode_paths'
  else
    echo 'FAIL xcode_paths'
    cat "$directory/run.log"
    failures=$((failures + 1))
  fi
}

failures=0
check_xcode_paths
check_schemes scheme_success success
check_schemes scheme_failure failure
check_schemes scheme_failure_with_match failure
check_schemes scheme_fallback success
check_selection build_iOS success
check_selection build_tvOS success
check_selection build_watchOS success
check_selection build_visionOS success
check_selection success success
check_selection success_tvOS success
check_selection success_watchOS success
check_selection success_visionOS success
check_selection already_booted success
check_selection download_success success
check_selection simulator_failure failure
check_selection discovery_failure failure
check_selection after_download_discovery_failure failure
check_selection download_failure failure
check_selection no_destination failure
check_selection boot_failure failure
check_selection unsupported_platform failure
[[ "$failures" == 0 ]]
