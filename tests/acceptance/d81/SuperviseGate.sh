#!/bin/sh
# tests/acceptance/d81/SuperviseGate.sh: D81 Supervisor Acceptance Verification Gate
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "${ROOT_DIR}"

if [ "$#" -ne 1 ]; then
  echo "Error: expected exactly one task id (for example, Task43601)" >&2
  exit 2
fi

TASK_ID="$1"
case "${TASK_ID}" in
  Task[0-9][0-9][0-9][0-9][0-9]) ;;
  *)
    echo "Error: unknown task id '${TASK_ID}'" >&2
    exit 2
    ;;
esac

TASK_DEFINITIONS=0
KNOWN_PHASE=""
for PHASE_FILE in .asl/mem/tasks/Phase*.asn; do
  if [ -f "${PHASE_FILE}" ]; then
    FILE_MATCHES=$(/usr/bin/grep -F -c ":id \"${TASK_ID}\"" "${PHASE_FILE}" || true)
    TASK_DEFINITIONS=$((TASK_DEFINITIONS + FILE_MATCHES))
    if [ "${FILE_MATCHES}" -gt 0 ]; then
      KNOWN_PHASE="${PHASE_FILE}"
    fi
  fi
done

if [ "${TASK_DEFINITIONS}" -eq 0 ]; then
  echo "Error: task '${TASK_ID}' is not registered in .asl/mem/tasks/Phase*.asn" >&2
  exit 2
fi

if [ "${TASK_DEFINITIONS}" -ne 1 ]; then
  echo "Error: task '${TASK_ID}' has ${TASK_DEFINITIONS} canonical definitions; refusing ambiguous dispatch" >&2
  exit 2
fi

FIXTURE="tests/acceptance/d81/${TASK_ID}.asl"
if [ ! -f "${FIXTURE}" ]; then
  echo "Error: required verifier fixture is missing: ${FIXTURE}" >&2
  echo "       registered task source: ${KNOWN_PHASE}" >&2
  exit 3
fi

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

echo "--> [1/3] Executing task fixture (${FIXTURE})..."
"${ASL_BIN}" test --strict-falsify "${FIXTURE}"

echo "--> [2/3] Executing pure ASL verification gates (bin/asl audit gates)..."
"${ASL_BIN}" audit gates

echo "--> [3/3] Executing sovereign consistency audit (bin/asl audit consistency)..."
"${ASL_BIN}" audit consistency

echo "================================================================================"
echo "✓ === [D81 Acceptance Gate] ALL SUPERVISOR VERIFICATIONS PASSED CLEANLY ==="
echo "================================================================================"
exit 0
