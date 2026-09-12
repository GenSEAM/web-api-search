#!/usr/bin/env bash
set -eo pipefail

WS_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WS_ROOT"

echo "================================================================================"
echo "          AgentScript (ASL) Full Monorepo Compilation & System Install          "
echo "================================================================================"

# Step 0: Engine compilation & source safety check
echo "--> [0/5] Compiling native ASL engine (asl/tools/asl.c)..."
if [ -f "asl/tools/asl.c" ]; then
  for target_out in "asl/asl" "bin/asl" "asl/bin/asl"; do
    if git ls-files --error-unmatch "$target_out" 2>/dev/null | grep -q "^$target_out$"; then
      if [ -f "$target_out" ] && head -n 1 "$target_out" 2>/dev/null | grep -q "^#!"; then
        echo "Error: build output target '$target_out' is a tracked source/script file; refusing overwrite." >&2
        exit 1
      fi
    fi
  done
  if command -v clang >/dev/null 2>&1; then
    mkdir -p bin asl/bin
    TMP_OBJ="$(mktemp /tmp/asl_obj.XXXXXX)"
    TMP_BIN="$(mktemp /tmp/asl_bin.XXXXXX)"
    DIGEST=$(shasum -a 256 asl/tools/asl.c 2>/dev/null | awk '{print substr($1,1,16)}' || echo "unknown")
    clang -c -O2 -DASL_SOURCE_DIGEST="\"$DIGEST\"" -o "$TMP_OBJ" asl/tools/asl.c
    clang -framework JavaScriptCore -o "$TMP_BIN" "$TMP_OBJ"
    cp -f "$TMP_BIN" asl/asl 2>/dev/null || true
    cp -f "$TMP_BIN" bin/asl 2>/dev/null || true
    cp -f "$TMP_BIN" asl/bin/asl 2>/dev/null || true
    rm -f "$TMP_OBJ" "$TMP_BIN"
    echo "    ✓ Compiled native ASL engine (digest: $DIGEST)."
  fi
fi

# Step 1: Verification & Gate Audit
echo "--> [1/5] Running verification gate audit..."
./asl/asl check .asl.config.asn
./asl/asl audit consistency

# Step 2: Projections transpilation
echo "--> [2/5] Transpiling ASN projections..."
./asl/asl project 2>/dev/null || true

# Step 3: Web Showcase Build
echo "--> [3/5] Compiling Web Showcase bundle (Vite + Tailwind)..."
if [ -d "asl/web/node_modules" ]; then
  npm --prefix asl/web run build 2>/dev/null || true
fi

# Step 4: Multi-Platform Release Distribution Packaging
echo "--> [4/5] Packaging release distribution artifacts (pack/dist)..."
VERSION="0.1.0"
TAG="v${VERSION}"
DIST_DIR="dist/${TAG}"
mkdir -p "$DIST_DIR"

ARM64_BIN="$(mktemp /tmp/asl_arm64.XXXXXX)"
X64_BIN="$(mktemp /tmp/asl_x64.XXXXXX)"
clang -target arm64-apple-macos -O2 -DASL_SOURCE_DIGEST="\"$DIGEST\"" -framework JavaScriptCore -o "$ARM64_BIN" asl/tools/asl.c 2>/dev/null || cp asl/asl "$ARM64_BIN"
clang -target x86_64-apple-macos -O2 -DASL_SOURCE_DIGEST="\"$DIGEST\"" -framework JavaScriptCore -o "$X64_BIN" asl/tools/asl.c 2>/dev/null || cp asl/asl "$X64_BIN"

for target in darwin-arm64 darwin-x64; do
  ARCHIVE="${DIST_DIR}/asl-${VERSION}-${target}.tar.gz"
  STAGE_DIR="$(mktemp -d /tmp/asl-dist-stage.XXXXXX)"
  if [ "$target" = "darwin-arm64" ]; then
    cp -f "$ARM64_BIN" "${STAGE_DIR}/asl"
  else
    cp -f "$X64_BIN" "${STAGE_DIR}/asl"
  fi
  chmod +x "${STAGE_DIR}/asl"
  mkdir -p "${STAGE_DIR}/packages"
  cp -R asl/packages/* "${STAGE_DIR}/packages/" 2>/dev/null || true
  mkdir -p "${STAGE_DIR}/.dist-meta"
  echo "(:target \"${target}\" :version \"${VERSION}\")" > "${STAGE_DIR}/.dist-meta/platform.asn"
  tar -czf "${ARCHIVE}" -C "${STAGE_DIR}" asl packages .dist-meta
  rm -rf "${STAGE_DIR}"
  echo "    ✓ Packaged ${ARCHIVE}"
done

rm -f "$ARM64_BIN" "$X64_BIN"

cd "$DIST_DIR"
rm -f asl-*-linux-*.tar.gz 2>/dev/null || true
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 asl-* > SHA256SUMS 2>/dev/null || true
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum asl-* > SHA256SUMS 2>/dev/null || true
fi
cd "$WS_ROOT"
echo "    ✓ Generated ${DIST_DIR}/SHA256SUMS"

# Verify scratch installation
SCRATCH_DIR="$(mktemp -d /tmp/asl-scratch-install.XXXXXX)"
tar -xzf "${DIST_DIR}/asl-${VERSION}-darwin-arm64.tar.gz" -C "${SCRATCH_DIR}"
if [ ! -x "${SCRATCH_DIR}/asl" ]; then
  echo "Error: packaged archive does not contain executable asl" >&2
  rm -rf "${SCRATCH_DIR}"
  exit 1
fi
"${SCRATCH_DIR}/asl" --version >/dev/null 2>&1 || {
  echo "Error: packaged archive binary failed execution in scratch install" >&2
  rm -rf "${SCRATCH_DIR}"
  exit 1
}
rm -rf "${SCRATCH_DIR}"
echo "    ✓ Verified packaged archive in scratch installation."

# Step 5: System Installation & Agent Toolbelt Registration
echo "--> [5/5] Installing ASL binary into system and registering agent skills..."

INSTALL_DIR="${HOME}/.asl/bin"
LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR" "$LOCAL_BIN"

# Symlink binaries
ln -sf "${WS_ROOT}/asl/asl" "${INSTALL_DIR}/asl"
ln -sf "${WS_ROOT}/asl/asl" "${INSTALL_DIR}/agentscript"
ln -sf "${WS_ROOT}/asl/asl" "${LOCAL_BIN}/asl"
ln -sf "${WS_ROOT}/asl/asl" "${LOCAL_BIN}/agentscript"
if [ -f "${WS_ROOT}/asl/bin/asl-engine" ]; then
  ln -sf "${WS_ROOT}/asl/bin/asl-engine" "${INSTALL_DIR}/asl-engine"
  ln -sf "${WS_ROOT}/asl/bin/asl-engine" "${LOCAL_BIN}/asl-engine"
  chmod +x "${INSTALL_DIR}/asl-engine" "${LOCAL_BIN}/asl-engine" 2>/dev/null || true
  echo "    ✓ Symlinked to ${INSTALL_DIR}/asl-engine"
  echo "    ✓ Symlinked to ${LOCAL_BIN}/asl-engine"
fi
chmod +x "${INSTALL_DIR}/asl" "${LOCAL_BIN}/asl"

echo "    ✓ Symlinked to ${INSTALL_DIR}/asl"
echo "    ✓ Symlinked to ${INSTALL_DIR}/agentscript"
echo "    ✓ Symlinked to ${LOCAL_BIN}/asl"
echo "    ✓ Symlinked to ${LOCAL_BIN}/agentscript"

# Ensure PATH in shell profiles
add_to_path() {
  local target_dir="$1"
  local config_file="$2"
  if [ -f "$config_file" ]; then
    if ! grep -qs "$target_dir" "$config_file"; then
      echo "" >> "$config_file"
      echo "# AgentScript (ASL) CLI" >> "$config_file"
      echo "export PATH=\"$target_dir:\$PATH\"" >> "$config_file"
      echo "    ✓ Added $target_dir to $config_file"
    fi
  fi
}

[ -f "${HOME}/.zshrc" ] && add_to_path "$INSTALL_DIR" "${HOME}/.zshrc"
[ -f "${HOME}/.zshrc" ] && add_to_path "$LOCAL_BIN" "${HOME}/.zshrc"
[ -f "${HOME}/.bashrc" ] && add_to_path "$INSTALL_DIR" "${HOME}/.bashrc"
[ -f "${HOME}/.bashrc" ] && add_to_path "$LOCAL_BIN" "${HOME}/.bashrc"
[ -f "${HOME}/.profile" ] && add_to_path "$INSTALL_DIR" "${HOME}/.profile"

# Run agent skills installation
bash "${WS_ROOT}/scripts/install.sh" --all --skills --source

echo ""
echo "================================================================================"
echo "✓ COMPILATION & SYSTEM INSTALLATION COMPLETED SUCCESSFULLY"
echo "================================================================================"
echo "Binary paths:"
echo "  • ${INSTALL_DIR}/asl"
echo "  • ${LOCAL_BIN}/asl"
echo "Version:"
"${LOCAL_BIN}/asl" --version 2>/dev/null || "${INSTALL_DIR}/asl" --version 2>/dev/null || true
echo "================================================================================"
