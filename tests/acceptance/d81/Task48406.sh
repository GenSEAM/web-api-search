#!/bin/bash
# tests/acceptance/d81/Task48406.sh: Dynamic Test Suite for Scope 2 (Phase 484)
# Verifies:
# 1. asl intel outline CLI command
# 2. asl mem lifecycle: replace -> diff -> flush -> discard
# 3. Cross-process In-RAM VFS staging persistence
# 4. ASN Batch RPC shortcodes: :out, :sec, :repl, :chk, :diff, :flush, :discard
# 5. Emits structured dynamic receipt to .asl/mem/receipts/task-48406-dynamic.asn
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "${ROOT_DIR}"

ASL_BIN="${ROOT_DIR}/bin/asl"
if [ ! -x "${ASL_BIN}" ]; then
  ASL_BIN="${ROOT_DIR}/asl/bin/asl"
fi

TOTAL_ASSERTS=0
assert_eq() {
  TOTAL_ASSERTS=$((TOTAL_ASSERTS + 1))
  local actual="$1"
  local expected="$2"
  local msg="$3"
  if [ "${actual}" != "${expected}" ]; then
    echo "[-] ASSERTION FAILED: ${msg}" >&2
    echo "    Expected: '${expected}'" >&2
    echo "    Actual:   '${actual}'" >&2
    exit 1
  fi
  echo "    ✓ [Assert ${TOTAL_ASSERTS}] ${msg}"
}

assert_contains() {
  TOTAL_ASSERTS=$((TOTAL_ASSERTS + 1))
  local haystack="$1"
  local needle="$2"
  local msg="$3"
  if ! echo "${haystack}" | grep -F -q "${needle}"; then
    echo "[-] ASSERTION FAILED: ${msg}" >&2
    echo "    Needle:   '${needle}'" >&2
    echo "    Haystack: '${haystack}'" >&2
    exit 1
  fi
  echo "    ✓ [Assert ${TOTAL_ASSERTS}] ${msg}"
}

echo "================================================================================"
echo "          Task48406 Dynamic Test Suite: Agent RPC & Memory Tooling              "
echo "================================================================================"

# ------------------------------------------------------------------------------
# Test 1: asl intel outline
# ------------------------------------------------------------------------------
echo "--> [1/4] Testing 'asl intel outline'..."
OUT_RES=$("${ASL_BIN}" intel outline asl/grammar/rpc.asn 2>&1)
assert_contains "${OUT_RES}" "(:outline :file \"asl/grammar/rpc.asn\"" "asl intel outline outputs canonical structure"
assert_contains "${OUT_RES}" ":symbols [" "asl intel outline includes symbols array"
assert_contains "${OUT_RES}" "(:op :name" "asl intel outline parses op entries from ASN"

# Test outline on Markdown file
SEC_MD_OUT=$("${ASL_BIN}" intel outline .plans/phase-484/PLAN.md 2>&1)
assert_contains "${SEC_MD_OUT}" "(:heading :name" "asl intel outline extracts markdown headings"

# ------------------------------------------------------------------------------
# Test 2: asl mem lifecycle (replace -> diff -> flush -> discard)
# ------------------------------------------------------------------------------
echo "--> [2/4] Testing 'asl mem' lifecycle..."
TMP_FILE="/tmp/t48406_lifecycle_${$}.txt"
echo "initial content tokenA rest of file" > "${TMP_FILE}"

# Replace
REPL_RES=$("${ASL_BIN}" mem replace "${TMP_FILE}" "tokenA" "tokenB" 2>&1)
assert_contains "${REPL_RES}" "(:mem-replace :status \"ok\"" "asl mem replace reports status ok"
assert_contains "${REPL_RES}" ":replacements 1 :modified true" "asl mem replace reports replacements count"

# Verify disk unchanged
DISK_CONTENT=$(cat "${TMP_FILE}")
assert_contains "${DISK_CONTENT}" "tokenA" "Disk content remains unmodified before flush"

# Diff
DIFF_RES=$("${ASL_BIN}" mem diff 2>&1)
assert_contains "${DIFF_RES}" "(:mem-diff :status \"ok\" :stagedCount 1" "asl mem diff reports 1 staged buffer"
assert_contains "${DIFF_RES}" ":modified true" "asl mem diff marks buffer as modified"

# Flush
FLUSH_RES=$("${ASL_BIN}" mem flush 2>&1)
assert_contains "${FLUSH_RES}" "(:mem-flush :status \"ok\" :flushedCount 1" "asl mem flush flushes 1 buffer"

# Verify disk updated
DISK_CONTENT_AFTER=$(cat "${TMP_FILE}")
assert_contains "${DISK_CONTENT_AFTER}" "tokenB" "Disk content updated with staged replacement after flush"

# Diff after flush should be 0
DIFF_AFTER=$("${ASL_BIN}" mem diff 2>&1)
assert_contains "${DIFF_AFTER}" ":stagedCount 0" "asl mem diff is empty after flush"

# Discard test
"${ASL_BIN}" mem replace "${TMP_FILE}" "tokenB" "tokenC" >/dev/null 2>&1
DIFF_DISCARD_1=$("${ASL_BIN}" mem diff 2>&1)
assert_contains "${DIFF_DISCARD_1}" ":stagedCount 1" "Buffer staged for discard test"
DISCARD_RES=$("${ASL_BIN}" mem discard 2>&1)
assert_contains "${DISCARD_RES}" "(:mem-discard :status \"ok\" :discardedCount 1" "asl mem discard reports discardedCount 1"
DISK_CONTENT_DISCARD=$(cat "${TMP_FILE}")
assert_contains "${DISK_CONTENT_DISCARD}" "tokenB" "Disk unchanged after discard"
rm -f "${TMP_FILE}"

# ------------------------------------------------------------------------------
# Test 3: Cross-process In-RAM VFS staging persistence
# ------------------------------------------------------------------------------
echo "--> [3/4] Testing Cross-Process In-RAM VFS staging persistence..."
CP_FILE="/tmp/t48406_crossproc_${$}.asl"
cat << 'ASLEOF' > "${CP_FILE}"
(module test/crossproc-test
  :d "Cross process test fixture"
  :x [target-fn]
  :i [])

(df target-fn [] -> Bool
  :d "Target function to replace"
  true)
ASLEOF

# Process 1: Stage replacement
"${ASL_BIN}" mem replace "${CP_FILE}" "target-fn" "mutated-fn" >/dev/null 2>&1

# Process 2: Verify intel outline reads from in-RAM staging across process boundary
CP_OUTLINE=$("${ASL_BIN}" intel outline "${CP_FILE}" 2>&1)
assert_contains "${CP_OUTLINE}" "mutated-fn" "Separate process intel outline reads staged symbol from memory"

# Process 3: Verify RPC :out reads from in-RAM staging across process boundary
CP_RPC_OUT=$("${ASL_BIN}" rpc "(:batch (:out \"${CP_FILE}\"))" 2>&1)
assert_contains "${CP_RPC_OUT}" "mutated-fn" "Separate process RPC :out reads staged symbol from memory"

# Process 4: Verify RPC :read reads from in-RAM staging across process boundary
CP_RPC_READ=$("${ASL_BIN}" rpc "(:batch (:read \"${CP_FILE}\" 1 10))" 2>&1)
assert_contains "${CP_RPC_READ}" "mutated-fn" "Separate process RPC :read reads staged content from memory"

# Process 5: Verify RPC :chk checks in-memory delimiters across process boundary
CP_RPC_CHK=$("${ASL_BIN}" rpc "(:batch (:chk \"${CP_FILE}\"))" 2>&1)
assert_contains "${CP_RPC_CHK}" ":op \"chk\" :status \"ok\" :allClean true" "Separate process RPC :chk verifies in-memory delimiter balance"

# Process 6: Flush and clean up
"${ASL_BIN}" mem flush >/dev/null 2>&1
CP_AFTER_FLUSH=$(cat "${CP_FILE}")
assert_contains "${CP_AFTER_FLUSH}" "mutated-fn" "Disk file contains mutated-fn after cross-process flush"
rm -f "${CP_FILE}"

# ------------------------------------------------------------------------------
# Test 4: Batch RPC Shortcodes (:out, :sec, :repl, :chk, :diff, :flush, :discard)
# ------------------------------------------------------------------------------
echo "--> [4/4] Testing ASN Batch RPC Shortcodes..."
BATCH_FILE="/tmp/t48406_batch_${$}.asl"
cat << 'ASLEOF' > "${BATCH_FILE}"
(module test/batch-test
  :d "Batch RPC test fixture"
  :x [calc-val]
  :i [])

(df calc-val [] -> Int64
  :d "Calculates value"
  42)
ASLEOF

# Multi-step batch: :out -> :repl -> :diff -> :chk -> :flush
BATCH_RES=$("${ASL_BIN}" rpc "(:batch (:out \"${BATCH_FILE}\") (:repl \"${BATCH_FILE}\" \"calc-val\" \"compute-val\") (:diff) (:chk \"${BATCH_FILE}\") (:flush))" 2>&1)
assert_contains "${BATCH_RES}" ":status \"completed\"" "Batch RPC completes successfully"
assert_contains "${BATCH_RES}" ":itemsCount 5" "Batch RPC executes all 5 steps"
assert_contains "${BATCH_RES}" "(:step :id 1 :op \"out\" :status \"ok\"" "Step 1 :out succeeds"
assert_contains "${BATCH_RES}" "(:step :id 2 :op \"repl\" :status \"ok\" :mode \"staged\"" "Step 2 :repl succeeds in staged mode"
assert_contains "${BATCH_RES}" "(:step :id 3 :op \"diff\" :status \"ok\" :stagedCount 1" "Step 3 :diff succeeds"
assert_contains "${BATCH_RES}" "(:step :id 4 :op \"chk\" :status \"ok\" :allClean true" "Step 4 :chk succeeds"
assert_contains "${BATCH_RES}" "(:step :id 5 :op \"flush\" :status \"ok\" :flushedCount 1" "Step 5 :flush succeeds"

# Verify disk updated
BATCH_DISK=$(cat "${BATCH_FILE}")
assert_contains "${BATCH_DISK}" "compute-val" "Disk updated via batch flush"

# In-memory delimiter failure detection test
BAD_BATCH_RES=$("${ASL_BIN}" rpc "(:batch (:repl \"${BATCH_FILE}\" \"compute-val\" \"broken-val (\") (:chk \"${BATCH_FILE}\") (:discard))" 2>&1)
assert_contains "${BAD_BATCH_RES}" "(:step :id 2 :op \"chk\" :status \"failed\" :allClean false" ":chk detects unbalanced delimiter in resident memory before flush"
assert_contains "${BAD_BATCH_RES}" "(:step :id 3 :op \"discard\" :status \"ok\"" "Discard safely clears corrupted staged buffer"

# Verify disk was NOT corrupted
BATCH_DISK_SAFE=$(cat "${BATCH_FILE}")
assert_contains "${BATCH_DISK_SAFE}" "compute-val" "Disk preserved safely despite memory delimiter corruption"
rm -f "${BATCH_FILE}"

# ------------------------------------------------------------------------------
# Emit Structured Dynamic Verification Receipt
# ------------------------------------------------------------------------------
mkdir -p .asl/mem/receipts
RECEIPT_FILE=".asl/mem/receipts/task-48406-dynamic.asn"
NOW_MS=$(python3 -c 'import time; print(int(time.time() * 1000))')
cat << RECEIPTEOF > "${RECEIPT_FILE}"
(:receipt
  :id "receipt-task-48406-dynamic"
  :taskId "Task48406"
  :gate "sh tests/acceptance/d81/Task48406.sh"
  :status :passed
  :exitCode 0
  :timestamp ${NOW_MS}
  :executedAsserts ${TOTAL_ASSERTS}
  :results [
    (:check :name "intel-outline" :status :passed)
    (:check :name "mem-lifecycle" :status :passed)
    (:check :name "crossproc-vfs" :status :passed)
    (:check :name "batch-shortcodes" :status :passed)
    (:check :name "in-memory-delimiter-guard" :status :passed)
  ]
)
RECEIPTEOF

echo "================================================================================"
echo "✓ === [Task48406 Dynamic Suite] ALL ${TOTAL_ASSERTS} DYNAMIC ASSERTIONS PASSED ==="
echo "================================================================================"
exit 0
