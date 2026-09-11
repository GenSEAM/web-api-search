#!/usr/bin/env bash
# AgentScript (ASL) Build-from-Source Bootstrap
# Auto-generated from pure AgentScript module: pack/src/dist.asl
set -eo pipefail

echo "🚀 [ASL] Building AgentScript from source (v0.1.0)...";
ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo "✗ Node.js runtime required for memory daemon bootstrap."; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "✗ AWK required for single-pass AST checking."; exit 1; }

echo "--> [1/3] Verifying ASL syntax and forms...";
chmod +x ./asl/asl 2>/dev/null || chmod +x ./asl
ASL_BIN="./asl/asl"
[ ! -f "$ASL_BIN" ] && ASL_BIN="./asl"

echo "--> [2/3] Running verification gates...";
"$ASL_BIN" gate

echo "--> [3/3] Setting up local binary symlinks...";
INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"
ln -sf "$(cd -P "$(dirname "$ASL_BIN")" && pwd)/$(basename "$ASL_BIN")" "$INSTALL_DIR/asl"
echo "✓ Successfully built and symlinked ASL to $INSTALL_DIR/asl";
echo "⚡ Run: asl --version";
