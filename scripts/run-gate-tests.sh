#!/usr/bin/env bash
# scripts/run-gate-tests.sh: Sovereign Pure Shell Parallel Gate Test Runner
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

EVAL_RUNNER="${1:-asl/bin/asl-eval}"
NODE_BIN="${2:-node}"

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

for arg in "$@"; do
  case "$arg" in
    --jobs=*|-j=*) WORKERS="${arg#*=}" ;;
    -j*) [ "${#arg}" -gt 2 ] && WORKERS="${arg#-j}" ;;
  esac
done

TMPDIR=$(mktemp -d /tmp/asl-gate-tests.XXXXXX)
trap 'rm -rf "$TMPDIR"' EXIT

# Find all asserting test files
TEST_FILES=()
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if grep -qE '\(assert[ \t]+' "$f" 2>/dev/null; then
    TEST_FILES+=("$f")
  fi
done < <(find . -name "*test*.asl" 2>/dev/null | grep -v 'node_modules' | grep -v '/\.' | grep -v '/corpus/invalid/' | sort)

export EVAL_RUNNER NODE_BIN TMPDIR

printf "%s\n" "${TEST_FILES[@]}" | xargs -n 1 -P "$WORKERS" -I {} bash -c '
  tf="$1"
  out_file=$(mktemp "$TMPDIR/test.XXXXXX")
  exit_code=0
  if [ -x "$EVAL_RUNNER" ] && [[ "$EVAL_RUNNER" != *.mjs && "$EVAL_RUNNER" != *.js ]]; then
    "$EVAL_RUNNER" "$tf" > "$out_file" 2>&1 || exit_code=$?
  elif [ -f "$EVAL_RUNNER" ] && command -v "$NODE_BIN" >/dev/null 2>&1; then
    "$NODE_BIN" "$EVAL_RUNNER" "$tf" > "$out_file" 2>&1 || exit_code=$?
  fi
  if [ "$exit_code" -ne 0 ]; then
    if grep -qE "(\[ASL_ASSERTION_FAILURE\]|ERR_ASSERTION_FAILED)" "$out_file"; then
      echo "FAIL:$tf" > "${out_file}.fail"
      cat "$out_file" >> "${out_file}.fail"
    fi
  fi
  rm -f "$out_file"
' _ {}

FAIL_FILES=( $(find "$TMPDIR" -name "*.fail" 2>/dev/null || true) )
if [ "${#FAIL_FILES[@]}" -gt 0 ]; then
  for sf in "${FAIL_FILES[@]}"; do
    f_name=$(head -n 1 "$sf" | sed 's/^FAIL://')
    echo "    ✗ Test suite failed under --strict-falsify: $f_name"
    tail -n +2 "$sf" | sed 's/^/      /'
  done
  exit 1
fi

exit 0
