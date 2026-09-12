#!/usr/bin/env bash
# scripts/run-gate-tests.sh: Sovereign Pure Shell Parallel Gate Test Runner
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

EVAL_RUNNER="${1:-asl/bin/asl-eval}"
NODE_BIN="${2:-node}"
TARGET_SCOPE="${3:-asl/packages/asl-gates/tests}"

# Calculate parallel workers
WORKERS=4
if command -v sysctl >/dev/null 2>&1; then
  NCPU=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
  WORKERS=$(( NCPU > 4 ? 4 : NCPU ))
elif command -v nproc >/dev/null 2>&1; then
  NCPU=$(nproc 2>/dev/null || echo 4)
  WORKERS=$(( NCPU > 4 ? 4 : NCPU ))
fi

if [ -n "${ASL_JOBS:-}" ]; then
  WORKERS="$ASL_JOBS"
elif [ -n "${JOBS:-}" ]; then
  WORKERS="$JOBS"
fi

TELEMETRY_OUT=""
COMPARE_BASELINE=""
STRICT_FALSIFY=0
POSITIONAL=()

while [ $# -gt 0 ]; do
  case "$1" in
    --jobs=*|-j=*) WORKERS="${1#*=}"; shift ;;
    -j) WORKERS="$2"; shift 2 ;;
    --telemetry-out=*|--telemetry=*) TELEMETRY_OUT="${1#*=}"; shift ;;
    --telemetry-out|--telemetry) TELEMETRY_OUT="$2"; shift 2 ;;
    --check-regression=*|--compare-baseline=*) COMPARE_BASELINE="${1#*=}"; shift ;;
    --check-regression|--compare-baseline) COMPARE_BASELINE="$2"; shift 2 ;;
    --strict-falsify) STRICT_FALSIFY=1; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

EVAL_RUNNER="${POSITIONAL[0]:-asl/bin/asl-eval}"
NODE_BIN="${POSITIONAL[1]:-node}"
TARGET_SCOPE="${POSITIONAL[2]:-asl/packages/asl-gates/tests}"

# If baseline check is requested, validate baseline existence and runner digest
BASELINE_ASSERTS=0
if [ -n "$COMPARE_BASELINE" ]; then
  if [ ! -f "$COMPARE_BASELINE" ]; then
    echo "Error: baseline file not found: $COMPARE_BASELINE" >&2
    exit 1
  fi
  DIGEST=$(grep -oE ':runnerDigest "[^"]+"' "$COMPARE_BASELINE" | sed -E 's/:runnerDigest "([^"]+)"/\1/' || true)
  if [ -z "$DIGEST" ] || [ "${#DIGEST}" -lt 8 ]; then
    echo "Error: baseline file lacks valid :runnerDigest (hand-written baseline rejected): $COMPARE_BASELINE" >&2
    exit 1
  fi
  BASELINE_ASSERTS=$(grep -oE ':executedAsserts [0-9]+' "$COMPARE_BASELINE" | awk '{print $2}' || echo 0)
  if [ "$BASELINE_ASSERTS" -le 0 ]; then
    echo "Error: baseline file has zero or unparseable :executedAsserts: $COMPARE_BASELINE" >&2
    exit 1
  fi
fi

TMPDIR=$(mktemp -d /tmp/asl-gate-tests.XXXXXX)
trap 'rm -rf "$TMPDIR"' EXIT

# Find all asserting test files
TEST_FILES=()
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if grep -qE '\(assert[ \t]+' "$f" 2>/dev/null; then
    TEST_FILES+=("$f")
  fi
done < <(find "${TARGET_SCOPE}" -name "*test*.asl" 2>/dev/null | grep -v 'node_modules' | grep -v '/\.' | grep -v '/corpus/invalid/' | sort)

export EVAL_RUNNER NODE_BIN TMPDIR STRICT_FALSIFY

START_ALL=$(perl -MTime::HiRes=time -e 'printf "%d\n", time*1000' 2>/dev/null || date +%s000)

if [ "${#TEST_FILES[@]}" -gt 0 ]; then
  printf "%s\n" "${TEST_FILES[@]}" | xargs -n 1 -P "$WORKERS" -I {} bash -c '
    tf="$1"
    out_file=$(mktemp "$TMPDIR/test.XXXXXX")
    res_file="${out_file}.res"
    t_start=$(perl -MTime::HiRes=time -e '\''printf "%d\n", time*1000'\'' 2>/dev/null || date +%s000)
    exit_code=0
    if [ -x "$EVAL_RUNNER" ] && [[ "$EVAL_RUNNER" != *.mjs && "$EVAL_RUNNER" != *.js ]]; then
      if [ "$STRICT_FALSIFY" -eq 1 ]; then
        "$EVAL_RUNNER" test --strict-falsify "$tf" > "$out_file" 2>&1 || exit_code=$?
      else
        "$EVAL_RUNNER" "$tf" > "$out_file" 2>&1 || exit_code=$?
      fi
    elif [ -f "$EVAL_RUNNER" ] && command -v "$NODE_BIN" >/dev/null 2>&1; then
      "$NODE_BIN" "$EVAL_RUNNER" "$tf" > "$out_file" 2>&1 || exit_code=$?
    fi
    t_end=$(perl -MTime::HiRes=time -e '\''printf "%d\n", time*1000'\'' 2>/dev/null || date +%s000)
    t_ms=$(( t_end - t_start ))

    exec_asserts=$(grep -oE "([0-9]+) assertion\(s\) executed" "$out_file" | awk "{print \$1}" || echo 0)
    exec_asserts=${exec_asserts:-0}
    exec_refutes=$(grep -oE "([0-9]+) refutation\(s\) executed" "$out_file" | awk "{print \$1}" || echo 0)
    exec_refutes=${exec_refutes:-0}

    cause="OK"
    if [ "$exit_code" -ne 0 ]; then
      if grep -qE "ERR_UNRESOLVED_IMPORT" "$out_file"; then
        cause="ERR_UNRESOLVED_IMPORT"
      elif grep -qE "ERR_UNBOUND_SYMBOL" "$out_file"; then
        cause="ERR_UNBOUND_SYMBOL"
      elif grep -qE "(\[ASL_ASSERTION_FAILURE\]|ERR_ASSERTION_FAILED|assertion failed)" "$out_file"; then
        cause="ASSERTION_FAILURE"
      else
        cause="OTHER_ERROR"
      fi
      echo "FAIL:$tf:$cause" > "${out_file}.fail"
      cat "$out_file" >> "${out_file}.fail"
    fi

    echo "$tf|$exit_code|$exec_asserts|$exec_refutes|$t_ms|$cause" > "$res_file"
    rm -f "$out_file"
  ' _ {}
fi

END_ALL=$(perl -MTime::HiRes=time -e 'printf "%d\n", time*1000' 2>/dev/null || date +%s000)
TOTAL_WALL_MS=$(( END_ALL - START_ALL ))

# Aggregate results
TOTAL_SUITES=${#TEST_FILES[@]}
PASSED_SUITES=0
FAILED_SUITES=0
TOTAL_EXECUTED=0
TOTAL_REFUTED=0
ASSERTION_FAILURES=0
UNRESOLVED_IMPORTS=0
UNBOUND_SYMBOLS=0
OTHER_ERRORS=0

while IFS='|' read -r tf ecode eassert erefute ems ecause; do
  [ -z "$tf" ] && continue
  TOTAL_EXECUTED=$(( TOTAL_EXECUTED + eassert ))
  TOTAL_REFUTED=$(( TOTAL_REFUTED + erefute ))
  if [ "$ecode" -eq 0 ]; then
    PASSED_SUITES=$(( PASSED_SUITES + 1 ))
  else
    FAILED_SUITES=$(( FAILED_SUITES + 1 ))
    case "$ecause" in
      ASSERTION_FAILURE) ASSERTION_FAILURES=$(( ASSERTION_FAILURES + 1 )) ;;
      ERR_UNRESOLVED_IMPORT) UNRESOLVED_IMPORTS=$(( UNRESOLVED_IMPORTS + 1 )) ;;
      ERR_UNBOUND_SYMBOL) UNBOUND_SYMBOLS=$(( UNBOUND_SYMBOLS + 1 )) ;;
      *) OTHER_ERRORS=$(( OTHER_ERRORS + 1 )) ;;
    esac
  fi
done < <(cat "$TMPDIR"/*.res 2>/dev/null || true)

RUNNER_DIGEST=$(printf "%s:%s:%s:%s" "$TOTAL_EXECUTED" "$TOTAL_REFUTED" "$PASSED_SUITES" "$FAILED_SUITES" | shasum -a 256 | awk '{print substr($1,1,16)}')

# Telemetry export if requested
if [ -n "$TELEMETRY_OUT" ]; then
  mkdir -p "$(dirname "$TELEMETRY_OUT")"
  cat > "$TELEMETRY_OUT" <<EOF
(:testTelemetry :v 2 :date "$(date +%Y-%m-%d)" :method "asl test per suite, stdout parsed for executed-assertion line and failure cause; parallel runner with digest"
  :runnerDigest "$RUNNER_DIGEST"
  :suites $TOTAL_SUITES :passedSuites $PASSED_SUITES :failedSuites $FAILED_SUITES
  :declaredAsserts 8555 :executedAsserts $TOTAL_EXECUTED :executedRefutes $TOTAL_REFUTED :totalWallMs $TOTAL_WALL_MS
  :failureCauses [
    (:cause "ASSERTION_FAILURE" :count $ASSERTION_FAILURES)
    (:cause "ERR_UNRESOLVED_IMPORT" :count $UNRESOLVED_IMPORTS)
    (:cause "ERR_UNBOUND_SYMBOL" :count $UNBOUND_SYMBOLS)
    (:cause "OTHER_ERROR" :count $OTHER_ERRORS)
  ])
EOF
  echo "Telemetry emitted to $TELEMETRY_OUT (digest: $RUNNER_DIGEST, executed: $TOTAL_EXECUTED)"
fi

# Baseline regression check
if [ -n "$COMPARE_BASELINE" ]; then
  if [ "$TOTAL_EXECUTED" -lt "$BASELINE_ASSERTS" ]; then
    echo "    ✗ Regression detected: executed assertions ($TOTAL_EXECUTED) dropped below baseline ($BASELINE_ASSERTS) from $COMPARE_BASELINE" >&2
    exit 1
  else
    echo "    ✓ Telemetry regression check passed: $TOTAL_EXECUTED executed assertions >= baseline ($BASELINE_ASSERTS)"
  fi
fi

# Failures check for normal gate runs
FAIL_FILES=( $(find "$TMPDIR" -name "*.fail" 2>/dev/null || true) )
if [ "${#FAIL_FILES[@]}" -gt 0 ]; then
  for sf in "${FAIL_FILES[@]}"; do
    header=$(head -n 1 "$sf")
    f_name=$(echo "$header" | awk -F':' '{print $2}')
    cause=$(echo "$header" | awk -F':' '{print $3}')
    echo "    ✗ Test suite failed under --strict-falsify [cause: $cause]: $f_name"
    tail -n +2 "$sf" | head -n 10 | sed 's/^/      /'
  done
  exit 1
fi

exit 0
