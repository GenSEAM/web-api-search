# Phase 1: TD-303 Batch RPC Error Resilience

## Acceptance Criterion
The Batch RPC engine and resident daemon socket must not crash or hang when receiving malformed S-expressions, invalid ASTs, nonexistent operations, or raw unparseable payloads (JSON/binary). When encountering errors, the daemon must return a structured error response containing `:status "error"` (or `:status "failed"` with closed error codes such as `:ERR_MALFORMED_SEXPR`, `:ERR_INVALID_AST`, or `:ERR_UNIMPLEMENTED`), keep the socket connection clean, and survive with continuous process liveness to serve subsequent valid requests immediately.

---

## Evidence & Current Behavior

1. **Silent Success on Malformed S-Expressions**:
   - In [asl/tools/asl.c:1551-1625](file:///Users/purplelephant/projects/asex/asl/tools/asl.c#L1551-L1625), `handle_payload` processes `(:batch ...)` by tracking parenthesis balance (`depth`). If an unclosed parenthesis or quote is passed (e.g. `(:batch (:read "rpc.asn" 1 5'`), `depth` never returns to 0, no steps are extracted (`step_count == 0`), and `failed_count == 0`.
   - Result: line 1606 emits `(:batch-res :status "completed" :items-count 0 :parallel true :results [])`.
   - Measured with `./bin/asl rpc '(:batch (:read "asl/grammar/rpc.asn" 1 5'`: exits 0, returning `:status "completed"` instead of reporting a syntax error.

2. **Daemon Socket Deadlock on Streaming / Unclosed Input**:
   - In [asl/tools/asl.c:1688-1744](file:///Users/purplelephant/projects/asex/asl/tools/asl.c#L1688-L1744), `run_serve` accepts client socket `cfd` without setting `SO_RCVTIMEO`.
   - The receive loop `while(1)` only terminates when `started && depth == 0` or when `recv` returns `<= 0`.
   - If a client sends data without balancing parentheses (such as JSON or unclosed batch forms) and does not call `shutdown(SHUT_WR)` immediately, `recv(cfd, ...)` blocks indefinitely.
   - Measured via Python test socket: sending `b"(:batch (:read \"test\"\n"` without closing the write end hangs `run_serve` indefinitely (`FAIL: daemon hung in recv loop (socket timeout)`), starving every other client trying to connect.

3. **Naive Parsing of Non-S-Expressions**:
   - In [asl/tools/asl.c:808-818](file:///Users/purplelephant/projects/asex/asl/tools/asl.c#L808-L818), `execute_single_step` treats any non-batch text as an operation, extracting tokens up to whitespace or colon.
   - Measured with `./bin/asl rpc '{"jsonrpc": "2.0"}'`: outputs `:op "{\"jsonrpc\"" :status "rejected" :error-code ":ERR_UNIMPLEMENTED"`, failing to identify the payload as an invalid AST / non-S-expression.

4. **Missing Node Host Daemon Bridge**:
   - [docs/LayerStratificationSpec.asn:102](file:///Users/purplelephant/projects/asex/docs/LayerStratificationSpec.asn#L102) and [docs/TestDebtAndFutureRefinements.asn:51](file:///Users/purplelephant/projects/asex/docs/TestDebtAndFutureRefinements.asn#L51) declare `asl/bridges/node/asl-daemon-host.mjs` as the canonical Layer 3 Node host daemon projection. Currently, this file does not exist.

---

## Ordered Work Items

### Item 1: S-Expression Syntax & AST Parsing Error Shield in Native Engine
- **Path**: `asl/tools/asl.c`
- **Why**: Prevent silent drop and false success on unclosed S-expressions or malformed syntax. Validate net parenthesis balance and quote closure before executing steps. If unbalanced or invalid AST, immediately output structured error:
  `(:batch-res :status "error" :error-code ":ERR_MALFORMED_SEXPR" :message "Malformed S-expression: unclosed delimiter" :items-count 1 :results [(:step :id 1 :op "batch" :status "error" :error-code ":ERR_SYNTAX" :message "Unclosed delimiter in S-expression")])`.
  For non-S-expression forms not starting with `(`, output `:ERR_INVALID_AST`.
- **Gate**:
  ```bash
  ./bin/asl rpc '(:batch (:read "asl/grammar/rpc.asn" 1 5' | grep -q ':status "error"'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  (:batch-res :status "completed" :items-count 0 :parallel true :results [
  ])
  ```
- **What breaks if run before previous item**: None (First execution item).
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/tools/asl.c"]`

---

### Item 2: Non-Blocking Socket Framing & Timeout Guards in Native Daemon
- **Path**: `asl/tools/asl.c`
- **Why**: Prevent daemon socket hangs when clients send unclosed S-expressions or stream frames without immediate TCP/UDS shutdown.
  1. Configure `SO_RCVTIMEO` (1000ms) on `cfd` in `run_serve` using `setsockopt`.
  2. Implement newline `\n` delimiter break-fallback matching framing conventions in `asl/packages/asl-sh/src/apm.asl:111-135`.
  3. When a frame fails to balance or times out, write structured `:status "error"` response, close `cfd`, and keep the server loop alive without crashing.
- **Gate**:
  ```bash
  bash -c '
  ./bin/asl --serve /tmp/td303_test.sock /Users/purplelephant/projects/asex /tmp/td303_test.pid >/dev/null 2>&1 &
  SERVER_PID=$!
  sleep 0.5
  python3 -c '\''
  import socket, sys
  s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
  s.settimeout(1.5)
  try:
      s.connect("/tmp/td303_test.sock")
      s.sendall(b"(:batch (:read \"test\"\n")
      res = s.recv(4096)
      if b":status \"error\"" in res:
          print("PASS")
          sys.exit(0)
      else:
          sys.exit(1)
  except socket.timeout:
      print("FAIL: daemon hung")
      sys.exit(2)
  finally:
      s.close()
  '\''
  EXIT_CODE=$?
  kill -9 $SERVER_PID 2>/dev/null || true
  rm -f /tmp/td303_test.sock /tmp/td303_test.pid
  exit $EXIT_CODE
  '
  ```
- **Current Verbatim Output**:
  ```text
  FAIL: daemon hung in recv loop (socket timeout)
  bash: line 26: 56758 Killed: 9               ./bin/asl --serve /tmp/td303_test.sock /Users/purplelephant/projects/asex /tmp/td303_test.pid > /dev/null 2>&1
  [Command exited with code 2]
  ```
- **What breaks if run before Item 1**: The socket timeout will unblock `recv`, but `handle_payload` without Item 1 will output `:status "completed" :items-count 0`, failing the gate asserting `:status "error"`.
- **Prerequisites (`depends_on`)**: `["asl/tools/asl.c"]` (Item 1)
- **File ownership (`owns`)**: `["asl/tools/asl.c"]`

---

### Item 3: Recompile Native ASL Engine & Synchronize Binaries
- **Path**: `asl/asl`, `bin/asl`
- **Why**: Native daemon fixes in `asl/tools/asl.c` must be compiled via clang with JavaScriptCore framework and deployed to both `asl/asl` and root `bin/asl`.
- **Gate**:
  ```bash
  clang -O2 -framework JavaScriptCore -o asl/asl asl/tools/asl.c && cp asl/asl bin/asl && ./bin/asl rpc '(:batch (:read "asl/grammar/rpc.asn" 1 5' | grep -q ':status "error"'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
- **What breaks if run before Items 1 and 2**: Compiling existing `asl.c` without changes simply reproduces the failing binary without `:status "error"`.
- **Prerequisites (`depends_on`)**: `["asl/tools/asl.c"]` (Items 1, 2)
- **File ownership (`owns`)**: `["asl/asl", "bin/asl"]`

---

### Item 4: Implement Node Host Daemon Bridge Projection
- **Path**: `asl/bridges/node/asl-daemon-host.mjs`
- **Why**: Satisfies the explicit architectural mandate in `docs/LayerStratificationSpec.asn:102` and TD-303 specification in `docs/TestDebtAndFutureRefinements.asn:51`.
  Provides the standalone Node.js daemon host bridge:
  1. UNIX domain socket server listening on `/tmp/asl_${USER}_global.sock` (or `--socket <path>`).
  2. Safe chunk framing and parenthesis balance counting.
  3. Defensive try/catch error handling returning `{:status "error", :error-code ":ERR_MALFORMED_INPUT"}` or `(:batch-res :status "error" ...)` on malformed S-expressions or JSON.
  4. Nonexistent operation rejection returning `:status "rejected" :error-code ":ERR_UNIMPLEMENTED"`.
  5. Uninterrupted socket liveness across fuzzing vectors.
- **Gate**:
  ```bash
  bash -c '
  node asl/bridges/node/asl-daemon-host.mjs --socket /tmp/td303_node_gate.sock --pid-file /tmp/td303_node_gate.pid >/dev/null 2>&1 &
  NODE_PID=$!
  sleep 0.5
  python3 -c '\''
  import socket, sys
  s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
  s.settimeout(1.5)
  try:
      s.connect("/tmp/td303_node_gate.sock")
      s.sendall(b"(:batch (:read \"test\"\n")
      s.shutdown(socket.SHUT_WR)
      res = b""
      while True:
          chunk = s.recv(4096)
          if not chunk:
              break
          res += chunk
      if b":status \"error\"" in res and b":ERR_MALFORMED_SEXPR" in res:
          print("PASS")
          sys.exit(0)
      else:
          sys.exit(1)
  except Exception:
      sys.exit(2)
  finally:
      s.close()
  '\''
  EXIT_CODE=$?
  kill -9 $NODE_PID 2>/dev/null || true
  rm -f /tmp/td303_node_gate.sock /tmp/td303_node_gate.pid
  exit $EXIT_CODE
  '
  ```
- **What breaks if run before Item 1**: Can run in parallel wave with Items 1–3 (disjoint files).
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/bridges/node/asl-daemon-host.mjs"]`

---

### Item 5: Adversarial RPC Fuzzing Acceptance Suite
- **Path**: `tests/acceptance/d81/TD303BatchRpcResilienceTest.sh`
- **Why**: Ground truth verification for TD-303. Tests the live daemon socket with:
  1. Unclosed S-expressions (`(:batch (:read ...`) -> asserts `:status "error"`.
  2. Malformed deep parens (`((((((((((`) -> asserts `:status "error"`.
  3. Raw JSON payload (`{"jsonrpc": "2.0"}`) -> asserts `:status "error"` and `:ERR_INVALID_AST`.
  4. Nonexistent operation (`(:nonexistent-op)`) -> asserts `:status "rejected"` / `:ERR_UNIMPLEMENTED`.
  5. Socket stall / unclosed write stream -> asserts response returned within 1.5s timeout.
  6. Liveness confirmation: asserts daemon PID is unchanged and responds with `(:ok :pong)` to valid `(:ping)`.
- **Gate**:
  ```bash
  test -f tests/acceptance/d81/TD303BatchRpcResilienceTest.sh && bash tests/acceptance/d81/TD303BatchRpcResilienceTest.sh
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
- **What breaks if run before Items 1–4**: Fuzzing will fail immediately due to socket hang and missing error statuses on unpatched daemons.
- **Prerequisites (`depends_on`)**: `["asl/tools/asl.c", "bin/asl", "asl/bridges/node/asl-daemon-host.mjs"]` (Items 1, 2, 3, 4)
- **File ownership (`owns`)**: `["tests/acceptance/d81/TD303BatchRpcResilienceTest.sh"]`

---

### Item 6: Update Test Debt Ledger for TD-303 Resolution
- **Path**: `docs/TestDebtAndFutureRefinements.asn`
- **Why**: Line 51 documents TD-303 as an active P0 test debt item. Once the fuzzing suite passes cleanly, mark TD-303 as resolved and record receipt reference.
- **Gate**:
  ```bash
  grep -E '\*\*TD-303\*\*' docs/TestDebtAndFutureRefinements.asn | grep -q 'RESOLVED'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
- **What breaks if run before Item 5**: Marking debt resolved before the adversarial fuzzing suite proves the fix is a verification violation.
- **Prerequisites (`depends_on`)**: `["tests/acceptance/d81/TD303BatchRpcResilienceTest.sh"]` (Item 5)
- **File ownership (`owns`)**: `["docs/TestDebtAndFutureRefinements.asn"]`

---

## Parallel Execution Waves

- **Wave 1 (Parallel Engine & Bridge Construction)**:
  - **Item 1 & Item 2 & Item 3**: `asl/tools/asl.c`, `asl/asl`, `bin/asl` (Native Engine Hardening)
  - **Item 4**: `asl/bridges/node/asl-daemon-host.mjs` (Layer 3 Node Host Bridge Projection)
- **Wave 2 (Integration & Adversarial Verification)**:
  - **Item 5**: `tests/acceptance/d81/TD303BatchRpcResilienceTest.sh`
- **Wave 3 (Ledger Settlement)**:
  - **Item 6**: `docs/TestDebtAndFutureRefinements.asn`

---

## Risks & Mitigations

1. **Risk: Socket Permission Quarantine in Sandboxed Test Runs**:
   - macOS sandbox restrictions may prevent non-sandboxed processes from accessing `/tmp/*.sock` created inside a sandbox.
   - *Mitigation*: Ensure daemon test harnesses use deterministic workspace-relative temporary socket paths or bypass sandbox flags during acceptance execution.
2. **Risk: Existing Client Compatibility with New `:status "error"`**:
   - Callers expecting `:status "failed"` when an individual step rejects might break if top-level syntax errors report `:status "error"`.
   - *Mitigation*: Maintain `:status "failed"` when steps execute but reject under `:ERR_UNIMPLEMENTED`, reserving `:status "error"` for unparseable S-expressions or malformed ASTs.

---

## Out of Scope

- **Multi-tenant Unix user credential authentication (`SO_PEERCRED`)**: ADR-0042 scopes the daemon socket per user (`/tmp/asl_${USER}_global.sock`). Kerberos/TLS authentication is deferred to distributed cluster transport.
- **Persistent process spooling and ring buffer rotation (TD-601/TD-602)**: These are addressed separately in Domain 6 of `TestDebtAndFutureRefinements.asn`.

---

## Opportunities & Suggestions

1. **Shared Tokenizer between ASL and C Host**: Currently, C host implements an ad-hoc tokenizer in `asl.c:401`. Compiling the pure ASL lexer to WASM or using unified delimiter tables will eliminate discrepancies between host and language runtime.
2. **Standardized Content-Length Framing**: Adopting HTTP-style `Content-Length:` framing natively across all client wrappers will completely eliminate stream tearing risks on multi-megabyte batch payloads.

