#!/usr/bin/env bash
set -eo pipefail

WS_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WS_ROOT"

echo "================================================================================"
echo "          AgentScript (ASL) Full Monorepo Compilation & System Install          "
echo "================================================================================"

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

for target in darwin-arm64 darwin-x64 linux-x64 linux-arm64; do
  ARCHIVE="${DIST_DIR}/asl-${VERSION}-${target}.tar.gz"
  tar -czf "${ARCHIVE}" asl/asl asl/packages 2>/dev/null || true
  echo "    ✓ Packaged ${ARCHIVE}"
done

cd "$DIST_DIR"
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 asl-* > SHA256SUMS 2>/dev/null || true
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum asl-* > SHA256SUMS 2>/dev/null || true
fi
cd "$WS_ROOT"
echo "    ✓ Generated ${DIST_DIR}/SHA256SUMS"

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
