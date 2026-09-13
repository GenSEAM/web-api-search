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
  Task[0-9][0-9][0-9][0-9][0-9]|Task-F[0-9][0-9]) ;;
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

DYNAMIC_SUITE="${ROOT_DIR}/tests/acceptance/d81/${TASK_ID}.sh"
if [ -f "${DYNAMIC_SUITE}" ]; then
  echo "--> [0/3] Executing dynamic integration suite (${DYNAMIC_SUITE})..."
  bash "${DYNAMIC_SUITE}"
fi

echo "--> [1/3] Executing task fixture (${FIXTURE})..."
FIXTURE_OUTPUT=$("${ASL_BIN}" test --strict-falsify "${FIXTURE}" 2>&1)
echo "${FIXTURE_OUTPUT}"

ZERO_PATTERN="0 assertion(s) executed"
if echo "${FIXTURE_OUTPUT}" | /usr/bin/grep -E -q "(^|[^0-9])0 assertion\(s\) executed" || echo "${FIXTURE_OUTPUT}" | /usr/bin/grep -F -q "0 assertions found"; then
  echo "Error: vacuous fixture execution detected (0 assertions evaluated in ${FIXTURE})" >&2
  exit 4
fi

EXECUTED_ASSERTS=$(echo "${FIXTURE_OUTPUT}" | /usr/bin/grep -oE "[0-9]+ assertion\(s\) executed" | /usr/bin/grep -oE "[0-9]+" | head -n 1 || true)
if [ -z "${EXECUTED_ASSERTS}" ] || [ "${EXECUTED_ASSERTS}" -eq 0 ]; then
  echo "Error: vacuous fixture execution detected (0 assertions evaluated in ${FIXTURE})" >&2
  exit 4
fi

echo "--> [2/3] Executing pure ASL verification gates (bin/asl audit gates)..."
"${ASL_BIN}" audit gates

echo "--> [3/3] Executing sovereign consistency audit (bin/asl audit consistency)..."
"${ASL_BIN}" audit consistency

echo "================================================================================"
echo "✓ === [D81 Acceptance Gate] ALL SUPERVISOR VERIFICATIONS PASSED CLEANLY ==="
echo "================================================================================"
exit 0
