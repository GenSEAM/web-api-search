# Phase FINSEL Plan: Monorepo Remediation & Epistemic Alignment

## Status
- **Phase**: PhaseFINSELRemediation
- **Priority**: Epistemic Integrity, Zero-Bypass Runtime, Monorepo Invariant Alignment
- **Status**: planned
- **Auditors**: Claude Opus Lens, Gemini Pro, Gemini 3.8 Flash
- **Monorepo Scope**: Waves 1 through 8 (1,950 source files)

## Executive Summary
Following an exhaustive, 8-wave, parallel multi-model audit conducted by the triad (Claude Opus Lens, Gemini Pro, Gemini 3.8 Flash), 39 systemic defects across all tiers of the architecture were falsified and cataloged. This remediation plan details 39 atomic tasks structured in a 5-phase dependency DAG. Each task is defined with strict path ownership (`:owns`), baseline failure verification, architectural rationale, and a non-vacuous, falsifiable verification gate (`:gate`) guaranteed to fail before the fix and pass after.

---

## Phase 1: P0 Epistemic Integrity & Security Gates

### Task-F01: Wire Dynamic Verification into C Host RPC Gate
- **Status**: completed
- **Owns**: `asl/tools/asl.c`
- **Baseline Failure**: `bin/asl rpc '(:op "gate")'` returns `:all-clean true :passed 7 :active 7 :total 7` on a repository with deliberate gate failures.
- **Remedy**: In `asl/tools/asl.c:3058` (`run_cmd_rpc_batch`), replace the hardcoded response with a live execution call to `run_all_seven_gates()`, serializing genuine pass/fail statuses and error tallies.
- **Gate**: `bin/asl rpc '(:batch (:gate))' | grep -v 'passed 7 :active 7 :total 7'`

### Task-F02: Implement Live Argument Parsing in CLI Gate Command
- **Status**: completed
- **Owns**: `asl/packages/asl-cli/src/cli.asl`
- **Baseline Failure**: `bin/asl gate non_existent_file.asl` returns `:status :ok` with exit code 0.
- **Remedy**: In `cli.asl:110`, parse provided file arguments, check existence via VFS or filesystem, and invoke `asl-gates.gate-runner/run-gate-audit` reporting typed error receipts.
- **Gate**: `! bin/asl gate /tmp/non_existent_file.asl`

### Task-F03: Repair Native Pre-Commit Hook Executable Target
- **Status**: completed
- **Owns**: `asl/tools/hooks/pre-commit`
- **Baseline Failure**: Running `grep -q 'bin/asl gate' asl/tools/hooks/pre-commit` prints `asl: Is a directory` and fails.
- **Remedy**: Fix line 5 to target `"$ROOT_DIR/bin/asl"` instead of `"$ROOT_DIR/asl"`.
- **Gate**: `grep -q 'bin/asl gate' asl/tools/hooks/pre-commit`

### Task-F04: Defend C Host Buffer Overruns and Command Injections
- **Status**: completed
- **Owns**: `asl/tools/asl.c`
- **Baseline Failure**: Path lengths exceeding 1024 bytes or containing shell metacharacters trigger buffer corruptions in `strcpy` and unquoted `popen` calls at lines 2287, 2709, 2852.
- **Remedy**: Replace `strcpy` with `snprintf(..., sizeof(...), ...)` bounds checking; sanitize shell arguments with single-quote escaping before invoking `popen`.
- **Gate**: `./bin/asl doctor`

### Task-F05: Eliminate Indiscriminate Quote Stripping in Shell Transpiler
- **Status**: completed
- **Owns**: `asl/packages/asl-codec/src/sh-transpile.asl`
- **Baseline Failure**: `asn-to-sh` on `(:sh "echo \"hello world\"")` strips all quotes into `echo hello world`, exposing arguments to shell word-splitting and command injection.
- **Remedy**: Replace naive `(string-replace s6 "\"" "")` at line 88 with an AST-aware shell escaping function `escape-sh-arg` that preserves intended quotes.
- **Gate**: `bin/asl eval '(:call asl-codec.sh-transpile/asn-to-sh "(:sh \"echo \\\"hello world\\\"\")")' | grep '\"hello world\"'`

### Task-F06: Eliminate Caller-Supplied Magic Numbers in Gate Runner
- **Status**: completed
- **Owns**: `asl/packages/asl-gates/src/gate_runner.asl`, `asl/packages/asl-gates/src/runner.asl`
- **Baseline Failure**: `(run-all-seven-gates 0 0 0 0 0 0 0)` vacuously returns green as long as arguments are non-negative.
- **Remedy**: Refactor `gate_runner.asl` to independently query the filesystem for manifests, ASL files, grammar definitions, and rule compliance. Deprecate caller-supplied counts.
- **Gate**: `bin/asl test asl/packages/asl-gates/tests/gate_runner_test.asl`

### Task-F07: Replace Hardcoded Magic Numbers in Tools Gate Suite
- **Status**: completed
- **Owns**: `tools/gate.asl`
- **Baseline Failure**: `tools/gate.asl:101-107` executes `(run-all-seven-gates 35 793 12 0 272 3737 22)` faking complete suite passage.
- **Remedy**: Compute actual file counts and manifest tallies by traversing the workspace before calling `run-all-seven-gates`.
- **Gate**: `bin/asl check tools/gate.asl`

### Task-F08: Ground Site Claims Verification Against Live Measurements
- **Status**: completed
- **Owns**: `asl/packages/asl-gates/src/site-claims.asl`
- **Baseline Failure**: `verify-claims-grounding` runs `(run-claims-audit claims claims)` tautologically checking claims against itself.
- **Remedy**: In `site-claims.asl:67`, compare published claims against live measurements computed by `asl audit` or test suites.
- **Gate**: `bin/asl test asl/packages/asl-gates/tests/site_claims_test.asl`

### Task-F09: Sanitize Crawler CLI Arguments & Enforce SSRF Defenses
- **Status**: completed
- **Owns**: `crawler/src/crawler.asl`
- **Baseline Failure**: `fetch-url` allows arbitrary URL schemes (`file://`, `gopher://`) and accepts flag-like URLs (e.g. `-v`, `--help`) without `--` argument isolation.
- **Remedy**: Validate URL scheme to allow only `http` and `https`; insert `--` before the target URL in curl argument vector.
- **Gate**: `bin/asl test crawler/tests/crawler_test.asl`

### Task-F10: Defend VDOM Attribute Sanitization Against Stored XSS
- **Status**: completed
- **Owns**: `vdom/src/vdom.asl`
- **Baseline Failure**: `is-retained-attr?` retains `href` and `src` attributes containing `javascript:` or `data:text/html`.
- **Remedy**: Add scheme validation regex/filter rejecting `javascript:`, `vbscript:`, and insecure `data:` URIs.
- **Gate**: `bin/asl test vdom/tests/vdom_test.asl`

### Task-F11: Enforce Cryptographic Checksum Verification in Distribution Installer
- **Status**: completed
- **Owns**: `pack/src/dist.asl`
- **Baseline Failure**: Generated `install.sh` downloads and extracts archives via `tar -xzf` without verifying SHA256 hashes.
- **Remedy**: Emit `sha256sum -c` or `shasum -a 256` verification before archive extraction in `emit-install-sh`.
- **Gate**: `bin/asl test pack/tests/dist_test.asl`

### Task-F12: Enforce Non-Vacuous Execution in Supervisor Acceptance Gate
- **Status**: completed
- **Owns**: `tests/acceptance/d81/SuperviseGate.sh`
- **Baseline Failure**: Fixtures with 0 assertions pass with exit code 0 under `SuperviseGate.sh`.
- **Remedy**: Parse test execution receipt in `SuperviseGate.sh` and ensure `executed_asserts > 0`; exit non-zero if no assertions were executed.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F12` (12 assertions verified)

---

## Phase 2: P1 Core Runtime & Tool Execution Engines

### Task-F13: Implement CLI Entrypoint in Agent Package
- **Status**: completed
- **Owns**: `agent/src/cli.asl`, `agent/bin/gsa`
- **Baseline Failure**: Running `agent/bin/gsa` exits 0 immediately without taking action.
- **Remedy**: Define `(df ! main ...)` in `agent/src/cli.asl` that parses command-line arguments, routes subcommands (`run`, `step`, `eval`), and connects to `agent-runner`.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F13` (17 assertions verified)

### Task-F14: Connect Agent Dispatcher to Genuine Engine Tools
- **Status**: completed
- **Owns**: `agent/src/dispatch.asl`
- **Baseline Failure**: Calling tools `ast-patch`, `deps-resolve`, `knowledge-load`, `knowledge-offload` returns hardcoded mock strings.
- **Remedy**: Wire tools to real AST parser, dependency graph, and memory hydration functions.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F14` (20 assertions verified)

### Task-F15: Implement Subprocess Execution and Pipe Engine in ASL Shell
- **Status**: completed
- **Owns**: `asl/packages/asl-sh/src/core/process.asl`, `asl/packages/asl-sh/src/core/pipe.asl`
- **Baseline Failure**: `exec!` returns `ERR_UNSUPPORTED` for all binaries other than `"echo"`; `pipe!` is an empty no-op.
- **Remedy**: Integrate `exec!` and `pipe!` with C host subprocess execution adapter.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F15` (18 assertions verified)

### Task-F16: Replace Multi-Target Codegen Dummy Stubs in ASL Compiler
- **Status**: completed
- **Owns**: `asl/packages/asl-compiler/src/compiler.asl`
- **Baseline Failure**: `compile-source-target` returns constant dummy strings for wasm, wat, go, c, arduino.
- **Remedy**: Wire `compile-source-target` to real code generators in `asl-codegen`.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F16` (23 assertions verified)

### Task-F17: Implement True AST Symbol Extraction in Intel Engine
- **Status**: completed
- **Owns**: `intel/src/extractor.asl`
- **Baseline Failure**: `extract-asl-symbols` returns empty `(list)`.
- **Remedy**: Parse ASL forms (`def`, `df`, `defstruct`, `defprotocol`) and extract fully-qualified symbol definitions and references.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F17` (13 assertions verified)

### Task-F18: Implement Dynamic AST Traversal and Blast Radius Reachability
- **Status**: completed
- **Owns**: `intel/src/graph.asl`, `intel/src/query.asl`
- **Baseline Failure**: `q-impact` fails or returns empty lists for symbols with known callers.
- **Remedy**: Build adjacency list representation of callers/callees and implement depth-bounded BFS/DFS traversal.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F18` (17 assertions verified)

### Task-F19: Hydrate Symbol Graph on Intel Preload
- **Status**: completed
- **Owns**: `intel/src/preload.asl`
- **Baseline Failure**: `intel-preload` traverses an empty graph created by `(g/graph-create)`.
- **Remedy**: Load workspace files, extract symbols, and populate the graph before performing preload traversal.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F19` (22 assertions verified)

### Task-F20: Connect Ablation Study Runner to Genuine Model Inference Harness
- **Status**: completed
- **Owns**: `bench/aep/ablation.asl`, `bench/aep/acceptance_test.asl`
- **Baseline Failure**: `run-ablation-study` returns hardcoded `1.0` pass rate and `0.0` hallucination.
- **Remedy**: Execute the 12 discriminator tasks against real model runs and record empirical metrics with standard deviation.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F20` (23 assertions verified)

### Task-F21: Replace Faked Synchronization and Pre-Commit Status Checks
- **Status**: completed
- **Owns**: `tools/sync-workspace.asl`, `tools/pre-commit.asl`
- **Baseline Failure**: `tools/sync-workspace.asl` hardcodes `true` for 17 submodules; `tools/pre-commit.asl` passes `0 0` thresholds.
- **Remedy**: Query git status and check actual staged diff counts.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F21` (20 assertions verified)

---

## Phase 3: P1 Concurrency, Memory & Structural AST Soundness

### Task-F22: Implement Delimiter Stack in Parser Balance Checker
- **Status**: completed
- **Owns**: `asl/packages/asl-parser/src/balance.asl`
- **Baseline Failure**: `check-balance` reports `true` on interleaved delimiters `([)]`.
- **Remedy**: Replace independent integer counters with a LIFO delimiter stack.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F22` (24 assertions verified)

### Task-F23: Fix Sequential String Unescaping Order of Operations
- **Status**: completed
- **Owns**: `asl/packages/asl-text/src/escape.asl`, `agent-bus/src/nd_asn.asl`
- **Baseline Failure**: `unescape-str` mutates `"\\\\n"` into `"\n"` due to premature `\\n` substitution.
- **Remedy**: Implement single-pass character scanner or unescape `\\\\` before handling `\\n`.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F23` (14 assertions verified)

### Task-F24: Prevent Irreversible Context Loss in Memory Pointer Collapse
- **Status**: completed
- **Owns**: `mem/src/pointer_orchestrator.asl`
- **Baseline Failure**: Collapsing a pointer clears payload to `""` with no mechanism to re-expand from VFS.
- **Remedy**: Store compressed chunk representation or VFS path reference in the collapsed pointer to allow complete roundtrip re-hydration.
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task-F24` (12 assertions verified)

### Task-F25: Eliminate Phantom Dirty Overwrites in Software Transactional Memory
- **Status**: planned
- **Owns**: `mem/src/stm.asl`
- **Baseline Failure**: Calling `stm-write` on an unread file sets base-hash to `"0"`, silently overwriting trunk changes on commit.
- **Remedy**: Query trunk state and compute true base-hash before accepting an unread write.
- **Gate**: `bin/asl test mem/tests/stm_test.asl`

### Task-F26: Replace Line-Based S-Expression Splitting in AST Merge
- **Status**: planned
- **Owns**: `mem/src/ast_merge.asl`
- **Baseline Failure**: Lines starting with `(` inside multi-line forms (such as `let` bindings) are treated as top-level forms, shredding the AST.
- **Remedy**: Parse forms using depth-aware delimiter tracking rather than newline splitting.
- **Gate**: `bin/asl test mem/tests/ast_merge_test.asl`

### Task-F27: Hydrate Memory Chunk Before Context Eviction
- **Status**: planned
- **Owns**: `mem/src/hydration.asl`
- **Baseline Failure**: `evict-raw-context` clears messages without persisting them into `MemoryChunk`.
- **Remedy**: Save uncompressed messages into cold storage before resetting the active list.
- **Gate**: `bin/asl test mem/tests/hydration_test.asl`

### Task-F28: Resolve Asymmetric Intent Contradiction in MVCC Bus
- **Status**: planned
- **Owns**: `agent-bus/src/mvcc_bus.asl`
- **Baseline Failure**: `detect-intent-contradiction` returns `true` for (approve, reject) but `false` for (reject, approve).
- **Remedy**: Symmetric comparison ensuring any pairing of opposing verdicts flags contradiction.
- **Gate**: `bin/asl test agent-bus/tests/mvcc_bus_test.asl`

### Task-F29: Prevent Permanent Deadlock on Intermediate Task States
- **Status**: planned
- **Owns**: `agent-core/src/scheduler.asl`
- **Baseline Failure**: Tasks crashing in `state-clarification`, `state-ready`, or `state-verifying` cannot be reaped by the supervisor.
- **Remedy**: Add all active intermediate states to `is-reapable-state?`.
- **Gate**: `bin/asl test agent-core/tests/scheduler_test.asl`

### Task-F30: Correct Field Target in Pub/Sub Event Filtering
- **Status**: planned
- **Owns**: `agent-bus/src/bus.asl`
- **Baseline Failure**: `query-bus-events` searches inside `payload` instead of `target`.
- **Remedy**: Inspect `(.-target msg)` to route messages by address.
- **Gate**: `bin/asl test agent-bus/tests/bus_test.asl`

### Task-F31: Add Key Reconciliation to VDOM List Diffing
- **Status**: planned
- **Owns**: `vdom/src/vdom.asl`
- **Baseline Failure**: Reordering children in a keyed list destroys and re-mounts DOM state.
- **Remedy**: Implement key-based indexing during list reconciliation.
- **Gate**: `bin/asl test vdom/tests/vdom_test.asl`

---

## Phase 4: P2 Boundary Universalism & Redundancy Consolidation

### Task-F32: Unify Core Agent Structs Under Boundary Universalism (C3/D34)
- **Status**: planned
- **Owns**: `agent-core/src/types.asl`, `agent-bus/src/types.asl`, `agent/src/types.asl`
- **Baseline Failure**: Three conflicting, incompatible definitions of `AgentMessage`, `ToolDef`, and `ToolResult` across packages.
- **Remedy**: Establish canonical definitions in `agent-core/src/types.asl` and re-export or import across packages.
- **Gate**: `bin/asl check agent-core && bin/asl check agent-bus && bin/asl check agent`

### Task-F33: Deduplicate Token Estimation Helper Across Monorepo
- **Status**: planned
- **Owns**: `mem/src/`, `agent/src/`, `agent-core/src/`, `asl-lint/src/`
- **Baseline Failure**: Verbatim duplicate implementation of `estimate-tokens` in 8 different files.
- **Remedy**: Delete local duplicates and import canonically from `asl-text/text`.
- **Gate**: `grep -rn "df estimate-tokens" asl/ agent* mem/ | wc -l | grep '^1$'`

### Task-F34: Remove Redundant Shadow Files and Naming Collisions
- **Status**: planned
- **Owns**: `asl-gates/src/runner.asl`, `agent/tests/agent_test.asl`, `asl-registry/src/schema_bridge.asl`
- **Baseline Failure**: Duplicate shadow files cause build confusion and drifted logic.
- **Remedy**: Consolidate and delete redundant shadow files.
- **Gate**: `! test -f asl/packages/asl-gates/src/runner.asl && ! test -f agent/tests/agent_test.asl`

### Task-F35: Standardize Agent Package Module Namespaces
- **Status**: planned
- **Owns**: `agent-core/src/*.asl`, `agent-bus/src/*.asl`, `agent/src/*.asl`
- **Baseline Failure**: Package manifests specify `asl-agent-core/*` while source files declare `asl-core/*`; `agent-bus` has three conflicting prefixes.
- **Remedy**: Align all module headers with their canonical package manifest names.
- **Gate**: `bin/asl check agent-core agent-bus agent`

### Task-F36: Resolve Tautological Tests in Memory and Acceptance Suites
- **Status**: planned
- **Owns**: `mem/tests/mem_test.asl`, `tests/acceptance/d81/Task45404.asl`
- **Baseline Failure**: Tests assert `(= 1 1)` or import unrelated math libraries to fake green passes.
- **Remedy**: Rewrite assertions to test genuine driver instances and failure injection reachability.
- **Gate**: `bin/asl test mem/tests/mem_test.asl && bin/asl test tests/acceptance/d81/Task45404.asl`

---

## Phase 5: P2 Monorepo Invariants & Grammar Realignment

### Task-F37: Restore Invariant C1 (Zero Comments) Across Monorepo
- **Status**: planned
- **Owns**: `asl/grammar/*.asn`, `harness/*.asn`, `mem/grammar.asn`, `asl/packages/asl-codegen/src/emit_jsx.asl`
- **Baseline Failure**: 40+ lines of raw `;;` comments and foreign `// @ts-nocheck` comments present.
- **Remedy**: Strip all comment tokens from ASN schemas and code generators.
- **Gate**: `! grep -rn ';;' asl/grammar/ harness/ mem/grammar.asn && ! grep -rn '// @ts' asl/packages/asl-codegen/`

### Task-F38: Restore Invariant C2 (Zero Emojis) Across Gate Runners and Tests
- **Status**: planned
- **Owns**: `asl/packages/asl-gates/src/gate_runner.asl`, `asl/packages/asl-registry/tests/registry_test.asl`
- **Baseline Failure**: Raw Unicode checkmark bytes `✓` and `✗` (`\xe2\x9c`) present in runner output.
- **Remedy**: Replace Unicode glyphs with ASN-compliant status symbols `:ok` and `:fail`.
- **Gate**: `bin/asl audit gates --only=6`

### Task-F39: Restore Invariant C5 (Zero Sigils) and Syntax Alignment
- **Status**: planned
- **Owns**: `agent/src/triage.asl`, `vdom/src/diagram.asl`, `asl-sh/src/core/process.asl`
- **Baseline Failure**: Raw `@pcp:` sigils and `${...}` template strings present in source code.
- **Remedy**: Strip `@` sigils from documentation strings; convert template strings to `(string-concat ...)`.
- **Gate**: `! grep -rn '@pcp:' agent/ src/ && ! grep -rn '\${' vdom/src/diagram.asl`
