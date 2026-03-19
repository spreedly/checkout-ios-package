#!/usr/bin/env bash
# Mirrors the release workflow "create-sdk-tag" job for local runs.
# Usage:
#   ./scripts/update_sdk_package_resolved_and_tag.sh <RELEASE_VERSION> [SDK_DIR]
#   ./scripts/update_sdk_package_resolved_and_tag.sh 1.2.4
#   ./scripts/update_sdk_package_resolved_and_tag.sh 1.2.4 /path/to/checkout-ios-sdk
# Optional:
#   --no-push       Update Package.resolved + xcodebuild resolve; do not commit/tag/push
#   --update-only   Only update Package.resolved version (no xcodebuild, no commit/tag/push)

set -e

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
  exit 1
fi

RESOLVED_FILE="Example/SpreedlySDKExample/SpreedlySDKExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

echo "📦 Release version: $RELEASE_VERSION"
echo "📂 SDK repo: $SDK_DIR"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "🔒 DRY RUN: will not commit, tag, or push"
fi
if [[ "$UPDATE_ONLY" -eq 1 ]]; then
  echo "📌 UPDATE ONLY: will not run xcodebuild resolve or TestFlight tag"
fi

if [[ ! -d "$SDK_DIR" ]]; then
  echo "❌ SDK directory not found: $SDK_DIR"
  exit 1
fi

cd "$SDK_DIR"
RESOLVED_PATH="$SDK_DIR/$RESOLVED_FILE"

if [[ ! -f "$RESOLVED_PATH" ]]; then
  echo "❌ Package.resolved not found at $RESOLVED_PATH"
  exit 1
fi

echo ""
echo "📝 Updating checkout-ios-package to version $RELEASE_VERSION in Package.resolved"
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
  echo "✅ Done (update only). Package.resolved now has checkout-ios-package @ $RELEASE_VERSION"
  exit 0
fi

echo ""
echo "🔧 Resolving dependencies (xcodebuild -resolvePackageDependencies)..."
echo "   Start: $(date)"
START=$(date +%s)

cd "$SDK_DIR/Example/SpreedlySDKExample"
MAX_RETRIES=3
RETRY_DELAY=15
attempt=1
while true; do
  echo "   Attempt $attempt/$MAX_RETRIES..."
  if xcodebuild -resolvePackageDependencies \
      -project SpreedlySDKExample.xcodeproj \
      -scheme SpreedlySDKExample; then
    echo "✅ Dependencies resolved successfully"
    break
  fi
  END=$(date +%s)
  echo "   Elapsed so far: $((END - START))s"
  if [[ $attempt -eq $MAX_RETRIES ]]; then
    echo "❌ Failed to resolve dependencies after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "⚠️ Resolve failed, retrying in ${RETRY_DELAY}s..."
  sleep $RETRY_DELAY
  attempt=$((attempt + 1))
done

END=$(date +%s)
echo "   End: $(date)"
echo "   Total resolve time: $((END - START))s"
echo ""
echo "📋 Updated Package.resolved (first 80 lines):"
head -n 80 "$RESOLVED_PATH"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo ""
  echo "🔒 DRY RUN: skipping commit, tag, and push."
  exit 0
fi

echo ""
echo "🏷️ Creating TestFlight tag and pushing..."
cd "$SDK_DIR"
git add "$RESOLVED_FILE"
git commit -m "Update Package.resolved to checkout-ios-package ${RELEASE_VERSION}" || echo "ℹ️ No changes to commit (Package.resolved already up to date)"

TAG_NAME="testflight-${RELEASE_VERSION}"
if git show-ref --verify --quiet "refs/tags/$TAG_NAME"; then
  echo "⚠️ Tag $TAG_NAME already exists, skipping creation"
else
  echo "🏷️ Creating tag: $TAG_NAME"
  git tag -a "$TAG_NAME" -m "TestFlight build for checkout-ios-package ${RELEASE_VERSION}"
  git push origin "$TAG_NAME"
  echo "✅ Tag $TAG_NAME created and pushed"
fi
