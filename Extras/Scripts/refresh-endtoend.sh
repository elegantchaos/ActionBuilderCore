#!/usr/bin/env bash
set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]
do
    SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    case "$SOURCE" in
        /*) ;;
        *) SOURCE="$SCRIPT_DIR/$SOURCE" ;;
    esac
done

SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACKAGE_DIR="$REPO_ROOT/Tests/EndToEndTests"
GENERATED_WORKFLOW="$PACKAGE_DIR/.github/workflows/EndToEndTests.yml"
ROOT_WORKFLOW="$REPO_ROOT/.github/workflows/EndToEndTests.yml"

cd "$REPO_ROOT"

swift build --product ActionBuilderTool
"$REPO_ROOT/.build/debug/ActionBuilderTool" "$PACKAGE_DIR"

if ! grep -q "working-directory: Tests/EndToEndTests" "$GENERATED_WORKFLOW"
then
    perl -0pi -e 's/on: \[push, pull_request\]/on: [push, pull_request]\n\ndefaults:\n  run:\n    working-directory: Tests\/EndToEndTests/s' "$GENERATED_WORKFLOW"
fi

mkdir -p "$(dirname "$ROOT_WORKFLOW")"
cp "$GENERATED_WORKFLOW" "$ROOT_WORKFLOW"

echo "Refreshed EndToEnd workflow at: $ROOT_WORKFLOW"
