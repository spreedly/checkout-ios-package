#!/usr/bin/env bash
# Manual 1.4.1 release on checkout-ios-package (after PR merge to main).
# Requires: ~/.spreedly-release-keys/ios/ios-bot-private.asc, gh CLI, write access.
set -euo pipefail

PKG_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEY_DIR="${HOME}/.spreedly-release-keys/ios"
TAG="1.4.1"
TITLE="Spreedly iOS SDK ${TAG}"

cd "$PKG_DIR"

gpg --batch --import "${KEY_DIR}/ios-bot-private.asc"
git config user.name "Spreedly iOS Release"
git config user.email "ybhatt@spreedly.com"
git config user.signingkey 2DE8551B78F59704

git checkout main
git pull origin main

# Tag signed commit on main (must be GPG-signed merge/sync commit).
git tag -s "${TAG}" -m "Release ${TAG}" --local-user 2DE8551B78F59704
git tag -v "${TAG}"
git push origin "${TAG}"

ASSETS=(
  sbom.json
  SpreedlyCore.zip SpreedlyCore.zip.sha256
  SpreedlySecurity.zip SpreedlySecurity.zip.sha256
  SpreedlyUI.zip SpreedlyUI.zip.sha256
  SpreedlyStripeAPM.zip SpreedlyStripeAPM.zip.sha256
  SpreedlyBraintree.zip SpreedlyBraintree.zip.sha256
)

gh release create "${TAG}" \
  --draft \
  --title "${TITLE}" \
  --notes-file CHANGELOG.md \
  "${ASSETS[@]}"

ATTACHED=$(gh release view "${TAG}" --json assets --jq '.assets | length')
test "${ATTACHED}" -eq 11

gh release edit "${TAG}" --draft=false
echo "Release ${TAG} published with ${ATTACHED} assets."
