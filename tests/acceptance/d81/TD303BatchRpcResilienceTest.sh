#!/bin/bash
# tests/acceptance/d81/TD303BatchRpcResilienceTest.sh
# Acceptance Suite: TD-303 Batch RPC Error Resilience & Socket Liveness
# Verifies both Native ASL C Daemon and Node Host Daemon Bridge projections.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "${ROOT_DIR}"

TEST_SOCK="/tmp/td303_fuzz_${$}.sock"
TEST_PID="/tmp/td303_fuzz_${$}.pid"
ASL_BIN="${ROOT_DIR}/bin/asl"
NODE_BRIDGE="${ROOT_DIR}/asl/bridges/node/asl-daemon-host.mjs"

CURRENT_DAEMON_PID=""

cleanup() {
  if [ -n "${CURRENT_DAEMON_PID}" ]; then
    kill -9 "${CURRENT_DAEMON_PID}" 2>/dev/null || true
  fi
  if [ -f "${TEST_PID}" ]; then
    SERVER_PID=$(cat "${TEST_PID}" 2>/dev/null || true)
    if [ -n "${SERVER_PID}" ]; then
      kill -9 "${SERVER_PID}" 2>/dev/null || true
    fi
    rm -f "${TEST_PID}"
  fi
  rm -f "${TEST_SOCK}"
}
trap cleanup EXIT INT TERM

# Helper python runner to execute adversarial socket requests
run_socket_fuzz() {
  local payload="$1"
  local close_write="${2:-true}"
  local timeout="${3:-2.0}"

  python3 -c "
import socket, sys, time

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(${timeout})
try:
    s.connect('${TEST_SOCK}')
    payload = ${payload}
    s.sendall(payload)
    if '${close_write}' == 'true':
        try:
            s.shutdown(socket.SHUT_WR)
        except:
            pass
    res = b''
    while True:
        chunk = s.recv(4096)
        if not chunk:
            break
        res += chunk
    sys.stdout.write(res.decode('utf-8', errors='replace'))
    sys.exit(0)
except socket.timeout:
    sys.stderr.write('SOCKET_TIMEOUT\n')
    sys.exit(124)
except Exception as e:
    sys.stderr.write(f'ERROR: {e}\n')
    sys.exit(1)
finally:
    s.close()
"
}

run_fuzz_matrix() {
  local target_name="$1"
  local start_cmd="$2"

  echo "--------------------------------------------------------------------------------"
  echo ">>> Testing Target: ${target_name}"
  echo "--------------------------------------------------------------------------------"

  rm -f "${TEST_SOCK}" "${TEST_PID}"
  CURRENT_DAEMON_PID=""

  eval "${start_cmd} >/dev/null 2>&1 &"
  CURRENT_DAEMON_PID=$!

  # Wait for daemon socket and pid file creation
  for i in {1..20}; do
    if [ -S "${TEST_SOCK}" ] && [ -f "${TEST_PID}" ]; then
      break
    fi
    sleep 0.1
  done

  if [ ! -S "${TEST_SOCK}" ]; then
    echo "[-] ERROR: [${target_name}] failed to create socket at ${TEST_SOCK}"
    exit 1
  fi

  INITIAL_PID=$(cat "${TEST_PID}")
  echo "[+] [${target_name}] active at ${TEST_SOCK} (PID: ${INITIAL_PID})"

  echo "--> [Vector 1/6] Fuzzing: Unclosed S-expression delimiter (half-closed socket)..."
  RES_1=$(run_socket_fuzz 'b"(:batch (:read \"asl/grammar/rpc.asn\" 1 5\n"' "true")
  echo "${RES_1}" | grep -q ':status "error"' || {
    echo "[-] FAILED Vector 1 on ${target_name}: Expected :status \"error\", got: ${RES_1}"
    exit 1
  }
  echo "${RES_1}" | grep -q ':ERR_MALFORMED_SEXPR' || {
    echo "[-] FAILED Vector 1 on ${target_name}: Expected :ERR_MALFORMED_SEXPR, got: ${RES_1}"
    exit 1
  }
  echo "[+] Vector 1 PASSED: Responded with structured delimiter error."

  echo "--> [Vector 2/6] Fuzzing: Deep unbalanced parentheses..."
  RES_2=$(run_socket_fuzz 'b"((((((((((\n"' "true")
  echo "${RES_2}" | grep -q ':status "error"' || {
    echo "[-] FAILED Vector 2 on ${target_name}: Expected :status \"error\", got: ${RES_2}"
    exit 1
  }
  echo "[+] Vector 2 PASSED: Deeply unbalanced S-expression rejected."

  echo "--> [Vector 3/6] Fuzzing: Raw non-S-expression JSON payload..."
  RES_3=$(run_socket_fuzz 'b"{\"jsonrpc\": \"2.0\", \"method\": \"ping\"}\n"' "true")
  echo "${RES_3}" | grep -q ':status "error"' || {
    echo "[-] FAILED Vector 3 on ${target_name}: Expected :status \"error\", got: ${RES_3}"
    exit 1
  }
  echo "${RES_3}" | grep -q ':ERR_INVALID_AST' || {
    echo "[-] FAILED Vector 3 on ${target_name}: Expected :ERR_INVALID_AST, got: ${RES_3}"
    exit 1
  }
  echo "[+] Vector 3 PASSED: Non-S-expression parsed as :ERR_INVALID_AST."

  echo "--> [Vector 4/6] Fuzzing: Nonexistent operation rejection..."
  RES_4=$(run_socket_fuzz 'b"(:nonexistent-op)\n"' "true")
  echo "${RES_4}" | grep -q ':status "rejected"' || {
    echo "[-] FAILED Vector 4 on ${target_name}: Expected :status \"rejected\", got: ${RES_4}"
    exit 1
  }
  echo "${RES_4}" | grep -q ':ERR_UNIMPLEMENTED' || {
    echo "[-] FAILED Vector 4 on ${target_name}: Expected :ERR_UNIMPLEMENTED, got: ${RES_4}"
    exit 1
  }
  echo "[+] Vector 4 PASSED: Nonexistent operation rejected with :ERR_UNIMPLEMENTED."

  echo "--> [Vector 5/6] Fuzzing: Socket stall without write-end closure..."
  # Stream without shutdown(SHUT_WR), client timeout set to 1.8s
  RES_5=$(run_socket_fuzz 'b"(:batch (:read \"stall-test\"\n"' "false" 1.8)
  echo "${RES_5}" | grep -q ':status "error"' || {
    echo "[-] FAILED Vector 5 on ${target_name}: Daemon hung or failed to return error on stall, got: ${RES_5}"
    exit 1
  }
  echo "[+] Vector 5 PASSED: Daemon unblocked via SO_RCVTIMEO/socket timeout within deadline."

  echo "--> [Vector 6/6] Daemon Liveness & Health Confirmation..."
  CURRENT_PID=$(cat "${TEST_PID}")
  if [ "${CURRENT_PID}" != "${INITIAL_PID}" ]; then
    echo "[-] FAILED Vector 6 on ${target_name}: Daemon PID changed (${INITIAL_PID} -> ${CURRENT_PID})"
    exit 1
  fi
  kill -0 "${CURRENT_PID}" 2>/dev/null || {
    echo "[-] FAILED Vector 6 on ${target_name}: Daemon process ${CURRENT_PID} died during fuzzing"
    exit 1
  }

  PING_RES=$(run_socket_fuzz 'b"(:ping)\n"' "true")
  echo "${PING_RES}" | grep -q '(:ok :pong)' || {
    echo "[-] FAILED Vector 6 on ${target_name}: Ping check failed, got: ${PING_RES}"
    exit 1
  }
  echo "[+] Vector 6 PASSED: Daemon survived all vectors; responded with (:ok :pong) (PID: ${CURRENT_PID})."

  # Clean shutdown of this daemon
  kill -9 "${CURRENT_PID}" 2>/dev/null || true
  rm -f "${TEST_SOCK}" "${TEST_PID}"
  CURRENT_DAEMON_PID=""
  sleep 0.2
}

echo "================================================================================"
echo "          TD-303 Acceptance Suite: Batch RPC Error Resilience Fuzzing           "
echo "================================================================================"

# Target 1: Native ASL C Sovereign Daemon
run_fuzz_matrix "Native ASL C Engine Daemon" "\"${ASL_BIN}\" --serve \"${TEST_SOCK}\" \"${ROOT_DIR}\" \"${TEST_PID}\""

# Target 2: Node Host Daemon Bridge Projection
run_fuzz_matrix "Node Host Daemon Bridge Projection" "node \"${NODE_BRIDGE}\" --socket \"${TEST_SOCK}\" --workspace \"${ROOT_DIR}\" --pid-file \"${TEST_PID}\""

echo "================================================================================"
echo "✓ === [TD-303 Acceptance Suite] ALL ADVERSARIAL FUZZING VECTORS PASSED ==="
echo "================================================================================"
exit 0
