#!/usr/bin/env bash
# AgentScript (ASL) Production Release Pipeline
# Auto-generated from pure AgentScript module: pack/src/release.asl
set -eo pipefail

VERSION="0.1.0"
TAG="v0.1.0"
ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "🚀 [ASL Release] Starting automated release for ${TAG}...";

# Step 1: Verification Gates
echo "--> [1/5] Executing complete 7-gate verification suite...";
./asl/asl gate

# Step 2: Prepare Release Output
echo "--> [2/5] Preparing release distribution directory...";
DIST_DIR="dist/${TAG}"
mkdir -p "$DIST_DIR"

# Step 3: Bundle Platform Archives
echo "--> [3/5] Packaging binary archives for target platforms...";
for target in darwin-arm64 darwin-x64 linux-x64 linux-arm64; do
  ARCHIVE="${DIST_DIR}/asl-${VERSION}-${target}.tar.gz"
  tar -czf "${ARCHIVE}" -C "${ROOT_DIR}" asl
  echo "    ✓ Built ${ARCHIVE}"
done
# Windows zip bundle
if command -v zip >/dev/null 2>&1; then
  zip -q "${DIST_DIR}/asl-${VERSION}-windows-x64.zip" asl
  echo "    ✓ Built ${DIST_DIR}/asl-${VERSION}-windows-x64.zip"
fi

# Step 4: Checksums
echo "--> [4/5] Generating cryptographic SHA256 checksums...";
cd "$DIST_DIR"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum asl-* > SHA256SUMS
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 asl-* > SHA256SUMS
fi
cd "$ROOT_DIR"

# Step 5: Web & NPM Publishing Preparation
echo "--> [5/5] Updating web distribution and version metadata...";
cp "$ROOT_DIR/npm/package.json" "$DIST_DIR/package.json"
echo "✓ Release ${TAG} packaged cleanly in ${DIST_DIR}.";
echo "⚡ Ready to tag and publish: git tag ${TAG} && git push origin ${TAG}";
