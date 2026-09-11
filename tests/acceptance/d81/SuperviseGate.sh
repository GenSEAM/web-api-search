#!/usr/bin/env bash
# tests/acceptance/d81/SuperviseGate.sh: D81 Supervisor Acceptance Verification Gate
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "${ROOT_DIR}"

ASL_BIN="${ROOT_DIR}/bin/asl"
if [ ! -x "${ASL_BIN}" ]; then
  ASL_BIN="${ROOT_DIR}/asl/bin/asl"
fi

if [ ! -x "${ASL_BIN}" ]; then
  echo "Error: ASL binary not found at ${ASL_BIN}" >&2
  exit 1
fi

echo "================================================================================"
echo "          D81 Acceptance Gate: Supervisor Verification & Ground Truth           "
echo "================================================================================"

echo "--> [1/2] Executing pure ASL verification gates (bin/asl audit gates)..."
"${ASL_BIN}" audit gates

echo "--> [2/2] Executing sovereign consistency audit (bin/asl audit consistency)..."
"${ASL_BIN}" audit consistency

echo "================================================================================"
echo "✓ === [D81 Acceptance Gate] ALL SUPERVISOR VERIFICATIONS PASSED CLEANLY ==="
echo "================================================================================"
exit 0
