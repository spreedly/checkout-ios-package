#!/usr/bin/env bash
# Mirrors the release workflow "create-sdk-tag" job for local runs.
# Usage:
#   ./scripts/update_sdk_package_resolved_and_tag.sh <RELEASE_VERSION> [SDK_DIR]
#   ./scripts/update_sdk_package_resolved_and_tag.sh 1.2.4
#   ./scripts/update_sdk_package_resolved_and_tag.sh 1.2.4 /path/to/checkout-ios-sdk
# Optional:
#   --no-push       Update Package.resolved + xcodebuild resolve; do not commit/tag/push
#   --update-only   Only update Package.resolved version (no xcodebuild, no commit/tag/push)

set -euo pipefail

RESOLVE_TIMEOUT=${RESOLVE_TIMEOUT:-600}
RESOLVE_MAX_RETRIES=${RESOLVE_MAX_RETRIES:-3}
RESOLVE_RETRY_DELAY=${RESOLVE_RETRY_DELAY:-15}

DRY_RUN=0
UPDATE_ONLY=0
RELEASE_VERSION=""
SDK_DIR=""
for arg in "$@"; do
  if [[ "$arg" == "--no-push" ]]; then
    DRY_RUN=1
  elif [[ "$arg" == "--update-only" ]]; then
    UPDATE_ONLY=1
  elif [[ -z "$RELEASE_VERSION" ]]; then
    RELEASE_VERSION="$arg"
  elif [[ -z "$SDK_DIR" ]]; then
    SDK_DIR="$arg"
  fi
done
SDK_DIR="${SDK_DIR:-$(cd "$(dirname "$0")/../.." && pwd)/checkout-ios-sdk}"
if [[ -z "$RELEASE_VERSION" ]]; then
  echo "Usage: $0 <RELEASE_VERSION> [SDK_DIR] [--no-push | --update-only]"
  echo "  --no-push     Update Package.resolved + xcodebuild resolve; do not commit/tag/push"
  echo "  --update-only Only update Package.resolved to released version (no resolve, no TestFlight)"
  echo ""
  echo "Environment variables:"
  echo "  RESOLVE_TIMEOUT     Seconds per xcodebuild attempt (default: 600)"
  echo "  RESOLVE_MAX_RETRIES Number of retry attempts (default: 3)"
  echo "  RESOLVE_RETRY_DELAY Seconds between retries (default: 15)"
  exit 1
fi

RESOLVED_FILE="Example/SpreedlySDKExample/SpreedlySDKExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

echo "=== Configuration ==="
echo "Release version:  $RELEASE_VERSION"
echo "SDK repo:         $SDK_DIR"
echo "Resolve timeout:  ${RESOLVE_TIMEOUT}s per attempt"
echo "Max retries:      $RESOLVE_MAX_RETRIES"
echo "Retry delay:      ${RESOLVE_RETRY_DELAY}s"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Mode:             DRY RUN (will not commit, tag, or push)"
fi
if [[ "$UPDATE_ONLY" -eq 1 ]]; then
  echo "Mode:             UPDATE ONLY (no xcodebuild resolve, no TestFlight tag)"
fi

echo ""
echo "=== Environment ==="
echo "Xcode:  $(xcodebuild -version 2>/dev/null | head -1 || echo 'not found')"
echo "Swift:  $(swift --version 2>/dev/null | head -1 || echo 'not found')"
echo "macOS:  $(sw_vers -productVersion 2>/dev/null || echo 'unknown')"
echo "Disk:   $(df -h / | tail -1 | awk '{print $4}') free"
echo "Date:   $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

if [[ ! -d "$SDK_DIR" ]]; then
  echo ""
  echo "FATAL: SDK directory not found: $SDK_DIR"
  exit 1
fi

cd "$SDK_DIR"
RESOLVED_PATH="$SDK_DIR/$RESOLVED_FILE"

echo ""
echo "=== Step 1: Validate Package.resolved ==="
if [[ ! -f "$RESOLVED_PATH" ]]; then
  echo "FATAL: Package.resolved not found at $RESOLVED_PATH"
  echo "Searching for Package.resolved files:"
  find "$SDK_DIR/Example" -name "Package.resolved" -type f 2>/dev/null || echo "  None found"
  exit 1
fi
echo "Found: $RESOLVED_PATH ($(wc -c < "$RESOLVED_PATH" | tr -d ' ') bytes)"

echo ""
echo "=== Step 2: Package.resolved BEFORE update ==="
python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for pin in data.get('pins', []):
    if pin['identity'] == 'checkout-ios-package':
        print(f'  checkout-ios-package version:  {pin[\"state\"].get(\"version\", \"unknown\")}')
        print(f'  checkout-ios-package revision: {pin[\"state\"].get(\"revision\", \"unknown\")}')
        break
else:
    print('  checkout-ios-package NOT FOUND in Package.resolved')
print(f'Total pins: {len(data.get(\"pins\", []))}')
print('All packages:')
for pin in data.get('pins', []):
    v = pin['state'].get('version', 'unknown')
    print(f'  - {pin[\"identity\"]} @ {v}')
" "$RESOLVED_PATH"

echo ""
echo "=== Step 3: Update version to $RELEASE_VERSION ==="
python3 -c "
import json, sys

version = sys.argv[1]
path = sys.argv[2]

with open(path) as f:
    data = json.load(f)

for pin in data.get('pins', []):
    if pin['identity'] == 'checkout-ios-package':
        old = pin['state'].get('version', 'unknown')
        pin['state']['version'] = version
        print(f'Updated checkout-ios-package: {old} -> {version}')
        break
else:
    print('ERROR: checkout-ios-package not found in Package.resolved')
    sys.exit(1)

data.pop('originHash', None)

with open(path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" "$RELEASE_VERSION" "$RESOLVED_PATH"

if [[ "$UPDATE_ONLY" -eq 1 ]]; then
  echo ""
  echo "Done (update only). Package.resolved now has checkout-ios-package @ $RELEASE_VERSION"
  exit 0
fi

echo ""
echo "=== Step 4: Resolve SPM dependencies ==="
cd "$SDK_DIR/Example/SpreedlySDKExample"

ATTEMPT=0
RESOLVE_SUCCESS=0
TOTAL_START=$(date +%s)

while [[ $ATTEMPT -lt $RESOLVE_MAX_RETRIES ]]; do
  ATTEMPT=$((ATTEMPT + 1))
  echo ""
  echo "--- Attempt $ATTEMPT/$RESOLVE_MAX_RETRIES (timeout: ${RESOLVE_TIMEOUT}s) ---"
  ATTEMPT_START=$(date +%s)

  xcodebuild -resolvePackageDependencies \
      -project SpreedlySDKExample.xcodeproj \
      -scheme SpreedlySDKExample &
  XCODE_PID=$!

  TIMED_OUT=0
  while kill -0 $XCODE_PID 2>/dev/null; do
    sleep 15
    ELAPSED=$(( $(date +%s) - ATTEMPT_START ))
    echo "   [${ELAPSED}s] Still resolving... (pid $XCODE_PID)"
    if [[ $ELAPSED -ge $RESOLVE_TIMEOUT ]]; then
      echo "   TIMEOUT: xcodebuild exceeded ${RESOLVE_TIMEOUT}s, killing pid $XCODE_PID"
      kill -9 $XCODE_PID 2>/dev/null || true
      wait $XCODE_PID 2>/dev/null || true
      TIMED_OUT=1
      break
    fi
  done

  if [[ $TIMED_OUT -eq 0 ]]; then
    wait $XCODE_PID
    XCODE_EXIT=$?
  else
    XCODE_EXIT=124
  fi

  ATTEMPT_END=$(date +%s)
  ATTEMPT_DURATION=$((ATTEMPT_END - ATTEMPT_START))
  echo "   Attempt $ATTEMPT finished: exit=$XCODE_EXIT, duration=${ATTEMPT_DURATION}s"

  if [[ $XCODE_EXIT -eq 0 ]]; then
    RESOLVE_SUCCESS=1
    break
  fi

  if [[ $ATTEMPT -lt $RESOLVE_MAX_RETRIES ]]; then
    if [[ $TIMED_OUT -eq 1 ]]; then
      echo "   Attempt timed out. Retrying in ${RESOLVE_RETRY_DELAY}s..."
    else
      echo "   Resolve failed (exit $XCODE_EXIT). Retrying in ${RESOLVE_RETRY_DELAY}s..."
    fi
    sleep $RESOLVE_RETRY_DELAY
  fi
done

TOTAL_END=$(date +%s)
TOTAL_DURATION=$((TOTAL_END - TOTAL_START))

if [[ $RESOLVE_SUCCESS -eq 1 ]]; then
  echo ""
  echo "Dependencies resolved successfully (total: ${TOTAL_DURATION}s)"
else
  echo ""
  echo "FATAL: Failed to resolve dependencies after $RESOLVE_MAX_RETRIES attempts (total: ${TOTAL_DURATION}s)"
  echo ""
  echo "=== Failure diagnostics ==="
  echo "Disk free: $(df -h / | tail -1 | awk '{print $4}')"
  CACHE_DIR=~/Library/Caches/org.swift.swiftpm
  if [[ -d "$CACHE_DIR" ]]; then
    echo "SPM cache size: $(du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')"
  fi
  echo "Package.resolved state:"
  cat "$RESOLVED_PATH"
  exit 1
fi

echo ""
echo "=== Step 5: Package.resolved AFTER resolve ==="
python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print(f'Total pins: {len(data.get(\"pins\", []))}')
print(f'originHash: {data.get(\"originHash\", \"MISSING\")}')
print('All packages:')
for pin in data.get('pins', []):
    v = pin['state'].get('version', 'unknown')
    r = pin['state'].get('revision', 'unknown')[:7]
    print(f'  - {pin[\"identity\"]} @ {v} ({r})')
" "$RESOLVED_PATH"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo ""
  echo "DRY RUN: skipping commit, tag, and push."
  exit 0
fi

echo ""
echo "=== Step 6: Create TestFlight tag ==="
cd "$SDK_DIR"
git add "$RESOLVED_FILE"
if git diff --cached --quiet; then
  echo "No changes to commit (Package.resolved already up to date)"
else
  git commit -m "Update Package.resolved to checkout-ios-package ${RELEASE_VERSION}"
  echo "Committed Package.resolved update"
fi

TAG_NAME="testflight-${RELEASE_VERSION}"
if git show-ref --verify --quiet "refs/tags/$TAG_NAME"; then
  echo "Tag $TAG_NAME already exists, skipping creation"
else
  echo "Creating tag: $TAG_NAME"
  git tag -a "$TAG_NAME" -m "TestFlight build for checkout-ios-package ${RELEASE_VERSION}"
  if git push origin "$TAG_NAME"; then
    echo "Tag $TAG_NAME created and pushed successfully"
  else
    echo "FATAL: Failed to push tag $TAG_NAME"
    exit 1
  fi
fi
