# Phase 467: Tool Reliability and Scenario Coverage

## Acceptance Criteria
1. **Tool Inventory Command & Affordance Visibility (Task46701)**:
   - Implement CLI command `asl inventory` and alias `asl doctor --inventory` in `asl/tools/asl.c`.
   - List all capabilities with dynamically measured status (`works`, `lies`, `partial`, `absent`) and declared fallbacks.
   - Synchronize with `asl/grammar/capabilities.asn` and ensure affordance-tier visibility via `scripts/install.sh`.
   - Maintain triple binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
   - Gate: `./bin/asl inventory`.
2. **Real Content Search & Bounded Process Handling (Task46703)**:
   - In `asl/tools/asl.c`, sever `:grep` from `:find` in `execute_single_step` (`asl/tools/asl.c:1513`).
   - Implement CLI command `asl grep <pattern> [path]` returning 1-indexed line numbers, file paths, and matched line spans (`path:line:content`).
   - `:grep` returns `:matches [ (:match :file "..." :line <n> :line-content "...") ... ]` and strictly never degrades to a filename glob list.
   - Register `:grep` operation distinctly in `asl/grammar/rpc.asn`.
   - In `asl/packages/asl-sh/src/` (`process.asl`, `spool.asl`), declare process lifetime, bounded execution, and explicit output truncation (`spool-truncate`).
   - Gate: `./bin/asl grep "int main" asl/tools/asl.c | grep -E -q "(4940|6246|[0-9]+:.*int main)" && ./bin/asl rpc '(:batch (:grep "int main" :file "asl/tools/asl.c"))' | grep -q ':line'`.
3. **Queryable Call-Graph and Impact Surface (Task46704)**:
   - Expose CLI subcommands `asl callers <sym>` and `asl impact <sym>` in `asl/tools/asl.c`, dispatching directly to AST walkers `callers_walker_cb` (`asl/tools/asl.c:841`) and `impact_walker_cb` (`asl/tools/asl.c:873`).
   - Align query surface representations with `intel/src` and `asl/grammar/rpc.asn`.
   - Gate: `./bin/asl callers make-note && ./bin/asl impact make-note`.
4. **Tool Scenario Matrix & Edge-Condition Test Suite (Task46702)**:
   - Author `tests/probes/tool_scenarios_test.asl` in pure ASL covering edge and fault scenarios: absent/missing file, path traversal (`../..`), empty pattern queries, bounded output truncation, and normal cases.
   - Run under `./bin/asl test --strict-falsify tests/probes/tool_scenarios_test.asl` with non-zero evaluated assertions.
   - Document scenario matrix doctrine in `docs/EXAMPLE_DOCTRINE.md`.
   - Gate: `./bin/asl test --strict-falsify tests/probes/tool_scenarios_test.asl`.
5. **Engine Residency and Process Model Specification (Task46705)**:
   - Author `docs/ENGINE_PROCESS_MODEL.md` specifying engine architecture (C host bootstrap embedding JavaScriptCore), session model (`:session-model`), process lifetime and timeout constraints (`:process-lifetime`), and workspace root determination (`:root-determination` via `discovered_ws`).
   - Formally define host engine protocol contracts in `asl/grammar/protocol-conformance.asn` with `:engine`.
   - Gate: `grep -q ':session-model' docs/ENGINE_PROCESS_MODEL.md && grep -q ':process-lifetime' docs/ENGINE_PROCESS_MODEL.md && grep -q ':root-determination' docs/ENGINE_PROCESS_MODEL.md`.
6. **Language Scenario Matrix and Undeclared Language Refusal (Task46706)**:
   - In `asl/grammar/capabilities.asn`, declare supported base languages per tool via `:supportedLanguages`.
   - Implement strict refusal of undeclared languages naming the language with `:ERR_UNSUPPORTED_LANGUAGE` in `intel/src/xref.asl` and `asl/tools/asl.c`.
   - Author and execute `tests/probes/language_matrix_test.asl` under `--strict-falsify`.
   - Gate: `./bin/asl rpc '(:batch (:out "test.xyz"))' | grep -q ':ERR_UNSUPPORTED_LANGUAGE' && ./bin/asl test --strict-falsify tests/probes/language_matrix_test.asl`.

---

## Invariant and Decision Tracking
- **C1 (0 Comments)**: Zero comments in all modified ASL, ASN, and configuration files.
- **C2 (0 Unicode Emojis)**: Zero raw unicode emojis across all surfaces.
- **C3 (Boundary Universalism)**: Canonical shared definitions in foundational packages; zero private duplicate helpers.
- **D51 (Token Efficiency Format)**: CamelCase for composite identifiers, structs, and tests.
- **D52 (Enriched Task Context)**: Complete context, outcomes, invariants, failure-modes, adr, and gate definitions.
- **D81 (Language Ground Truth)**: Pure ASL inside packages, declared C host boundary, independent verification fixtures.
- **hiddenTests**: Grader acceptance fixtures owned strictly by independentVerifier.

---

## Ordered Work Items

### Item 1: Tool Inventory Command with Measured Status and Fallbacks (Task46701)
- **Path**: `asl/tools/asl.c:5836-5950`, `asl/tools/asl.c:6473-6503`, `asl/grammar/capabilities.asn`, `scripts/install.sh`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-1"` / `"Task46701"`
  - `:title`: `"Implement tool inventory command with measured status and declared fallbacks"`
  - `:kind`: `:tooling`
  - `:lane`: `"inventory"`
- **Why**: Task46701, Invariant D81, and ADR-0081: An agent cannot choose well among tools it cannot enumerate. Currently `asl/tools/asl.c` measures 36 capabilities into `capabilities.lock` via `run_cmd_doctor`, but provides no CLI command for an agent to inspect the active inventory, measured statuses (`works`, `lies`, `partial`, `absent`), and declared fallbacks. Subcommand `asl inventory` (and alias `asl doctor --inventory`) exposes this dynamically from probe results.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Provide unified CLI tool inventory with dynamically measured statuses and declared fallbacks rendered at the affordance tier.
  - `:outcomes`:
    - `asl inventory` lists all 36 capabilities with status and fallback.
    - `asl doctor --inventory` functions as an alias.
    - Dynamic reflection of broken tools without manual edits.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Exact column/entry formatting and exit code 0.
  - `:failure-modes`: Discrepancy between probe results and printed inventory; missing binary target sync.
  - `:additional-requirements`: Must recompile and synchronize `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["run_cmd_inventory", "run_cmd_doctor", "g_canonical_caps"]`
  - `:action-dag`:
    1. Inspect `g_canonical_caps` (`asl/tools/asl.c:5836-5873`) and `run_cmd_doctor` (`asl/tools/asl.c:5875-5950`).
    2. Implement `run_cmd_inventory` in `asl/tools/asl.c` iterating canonical capabilities and executing probe evaluations.
    3. Dispatch `inventory` in `main()` dispatcher (`asl/tools/asl.c:6473`) and add alias for `doctor --inventory`.
    4. Synchronize definitions in `asl/grammar/capabilities.asn` and affordance visibility in `scripts/install.sh`.
    5. Recompile C engine and synchronize `bin/asl`, `asl/bin/asl`, and `asl/asl`.
    6. Execute gate command `./bin/asl inventory`.
- **Gate**:
  ```bash
  ./bin/asl inventory
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: unrecognized subcommand 'inventory'
  ```
  *(Exit code 1; fails because subcommand 'inventory' is not recognized in asl/tools/asl.c)*
- **Prerequisites (`depends_on`)**: `[]`
- **What breaks if executed out of order**:
  No item precedes Item 1. It provides baseline affordance discoverability needed to inspect tool status throughout subsequent phases.
- **File ownership (`owns`)**:
  `["asl/tools/asl.c", "asl/grammar/capabilities.asn", "scripts/install.sh", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task46701.asl"]`

---

### Item 2: Real Content Search & Bounded Process Handling (Task46703)
- **Path**: `asl/tools/asl.c:1513-1580`, `asl/tools/asl.c:6470-6720`, `asl/grammar/rpc.asn`, `asl/packages/asl-sh/src/process.asl`, `asl/packages/asl-sh/src/spool.asl`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-2"` / `"Task46703"`
  - `:title`: `"Separate :grep from :find, implement content search CLI, and enforce bounded process handling"`
  - `:kind`: `:engine`
  - `:lane`: `"coverage"`
- **Why**: Task46703, Invariant C3, ADR-0081, Blocker 2, and Blocker 4:
  - In `asl/tools/asl.c:1513`, `:grep` is currently aliased directly to `:find` (`if (strcmp(op, "find") == 0 || strcmp(op, "grep") == 0)`), searching only file names and returning file globs instead of searching file contents.
  - Subcommand `asl grep` is absent (`Error: unrecognized subcommand 'grep'`).
  - `:grep` must perform real content search across text files, returning matching file paths, 1-indexed line numbers, and line text: `(:matches [ (:match :file "..." :line <n> :line-content "...") ... ])`.
  - When zero matches are found, `:grep` must return `:count 0 :matches []` and strictly never degrade into a filename glob list.
  - Implement CLI subcommand `asl grep <pattern> [path]` printing matched lines with line numbers and file paths (`path:line:content`).
  - Process handling in `asl/packages/asl-sh/src/` must declare how a process is started, its lifetime, and how output is bounded: a process producing unbounded output is truncated at a stated bound (`spool-truncate` via `RingBuffer` and `DiskSpool`) and explicitly reports that it was truncated.
  - In `asl/grammar/rpc.asn`, register `:grep` distinctly under search operations.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Eliminate deceptive search degradation by providing truthful content search in CLI and RPC batch interfaces, coupled with bounded process execution and output truncation.
  - `:outcomes`:
    - `asl grep <pattern> [path]` searches file contents and prints line coordinates with text spans.
    - RPC `(:batch (:grep ...))` returns `:line` and `:line-content`.
    - `:grep` never degrades to `:find` or filename lists.
    - Unbounded process output in `asl-sh` is truncated at the declared bound with explicit truncation status.
    - RPC registry in `asl/grammar/rpc.asn` updated.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Enforce bounded match limits (default max 100 results) to prevent unbounded memory allocation.
  - `:failure-modes`: Buffer overflow on oversized lines; path traversal escaping workspace root.
  - `:additional-requirements`: Must recompile and synchronize `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["run_cmd_grep", "grep_walker_cb", "execute_single_step", "RingBuffer", "spool-truncate"]`
  - `:action-dag`:
    1. Sever `:grep` from `:find` in `asl/tools/asl.c:1513`.
    2. Implement `grep_walker_cb` in `asl/tools/asl.c` to open candidate files, scan lines for pattern, and collect matching lines with line numbers.
    3. Implement `run_cmd_grep` in `asl/tools/asl.c` and dispatch `asl grep` in `main()`.
    4. Register `:grep` operation schema in `asl/grammar/rpc.asn`.
    5. Update process supervision and output truncation in `asl/packages/asl-sh/src/process.asl` and `spool.asl` to ensure explicit truncation notice when bounds are exceeded.
    6. Recompile native engine and synchronize `bin/asl`, `asl/bin/asl`, and `asl/asl`.
    7. Execute gate command asserting CLI line output and RPC `:line` structural attributes.
- **Gate**:
  ```bash
  ./bin/asl grep "int main" asl/tools/asl.c | grep -E -q "(4940|6246|[0-9]+:.*int main)" && ./bin/asl rpc '(:batch (:grep "int main" :file "asl/tools/asl.c"))' | grep -q ':line'
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: unrecognized subcommand 'grep'
  ```
  *(Exit code 1; fails because 'asl grep' is unrecognized and RPC :grep returns (:step :op "find" ... :files []) which lacks the ':line' attribute)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **What breaks if executed out of order**:
  If Item 2 runs before Item 1, tool discovery via `asl inventory` will report unverified or absent content search status, breaking affordance transparency.
- **File ownership (`owns`)**:
  `["asl/tools/asl.c", "asl/grammar/rpc.asn", "asl/packages/asl-sh/src", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task46703.asl"]`

---

### Item 3: Queryable Call-Graph and Impact Surface (Task46704)
- **Path**: `asl/tools/asl.c:841-905`, `asl/tools/asl.c:1455-1512`, `asl/tools/asl.c:6470-6720`, `intel/src`, `asl/grammar/rpc.asn`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-3"` / `"Task46704"`
  - `:title`: `"Expose queryable call-graph and impact analysis via CLI subcommands"`
  - `:kind`: `:tooling`
  - `:lane`: `"graph"`
- **Why**: Task46704, Invariant C3, and ADR-0081:
  - Codebase dependency analysis is essential for assessing blast radius before changes.
  - In `asl/tools/asl.c:1455-1512`, AST call graph walkers (`callers_walker_cb` at line 841 and `impact_walker_cb` at line 873) power RPC batch operations `:callers` and `:impact`.
  - However, direct CLI subcommands `asl callers <sym>` and `asl impact <sym>` fail with `Error: unrecognized subcommand 'callers'`.
  - Exposing `asl callers <sym>` and `asl impact <sym>` gives agents direct visibility into callers, dependents, and blast radius without having to assemble batch RPC payloads.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Make call-graph and impact analysis immediately accessible via standard CLI invocation.
  - `:outcomes`:
    - `asl callers <sym>` prints all caller definition sites with file paths and line numbers.
    - `asl impact <sym>` prints blast radius affected files and nodes.
    - Both subcommands exit 0 on valid queries and 1 on missing arguments.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Format output cleanly with line counts and file references.
  - `:failure-modes`: Missing symbol argument; buffer overflow on dense call graphs.
  - `:additional-requirements`: Recompile and synchronize `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["run_cmd_callers", "run_cmd_impact", "callers_walker_cb", "impact_walker_cb"]`
  - `:action-dag`:
    1. Inspect `callers_walker_cb` (`asl/tools/asl.c:841`) and `impact_walker_cb` (`asl/tools/asl.c:873`).
    2. Implement `run_cmd_callers` and `run_cmd_impact` functions in `asl/tools/asl.c`.
    3. Dispatch `callers` and `impact` subcommands in `main()` dispatcher (`asl/tools/asl.c:6473`).
    4. Recompile native engine and update `bin/asl`, `asl/bin/asl`, and `asl/asl`.
    5. Verify gate command `./bin/asl callers make-note && ./bin/asl impact make-note`.
- **Gate**:
  ```bash
  ./bin/asl callers make-note && ./bin/asl impact make-note
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: unrecognized subcommand 'callers'
  ```
  *(Exit code 1; fails because 'callers' subcommand is not recognized by asl/tools/asl.c)*
- **Prerequisites (`depends_on`)**: `["item-2"]`
- **What breaks if executed out of order**:
  If Item 3 runs before Item 2, concurrent edits to `asl/tools/asl.c` risk dispatch table merge conflicts, and dependency analysis queries on search functions would execute while `:grep` is still aliased to `:find`.
- **File ownership (`owns`)**:
  `["asl/tools/asl.c", "intel/src", "asl/grammar/rpc.asn", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task46704.asl"]`

---

### Item 4: Tool Scenario Matrix & Edge-Condition Test Suite (Task46702)
- **Path**: `tests/probes/tool_scenarios_test.asl`, `docs/EXAMPLE_DOCTRINE.md`
- **Identity**:
  - `:id`: `"item-4"` / `"Task46702"`
  - `:title`: `"Author tool scenario matrix covering edge conditions under strict falsification"`
  - `:kind`: `:verification`
  - `:lane`: `"coverage"`
- **Why**: Task46702, Invariant D81, and ADR-0081:
  - Happy-path tests are insufficient to guarantee tool reliability; silent degradations occur when edge conditions are never tested.
  - Tools must be subjected to a systematic scenario matrix:
    1. Absent / non-existent target files (`test-missing-file` returning `:ERR_FILE_NOT_FOUND`).
    2. Directory traversal escaping workspace boundary (`test-path-traversal` returning refusal/boundary violation).
    3. Empty query / search pattern strings (rejecting cleanly or returning empty).
    4. Bounded output ceiling verification (`test-bounded-output`).
    5. Normal case verification.
  - Author `tests/probes/tool_scenarios_test.asl` in pure ASL with non-zero evaluated assertions under `--strict-falsify`.
  - Update `docs/EXAMPLE_DOCTRINE.md` with scenario matrix requirements.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Establish an executable scenario test suite that asserts on failure modes and boundary defenses for all core tools.
  - `:outcomes`:
    - `tests/probes/tool_scenarios_test.asl` created.
    - Suite executes non-zero assertions and passes under `--strict-falsify`.
    - Silent degradation in tool error handling is immediately caught.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Native ASL `(assert ...)` forms.
  - `:failure-modes`: Unbound symbols causing early evaluation termination; zero executed assertions under `--strict-falsify`.
  - `:additional-requirements`: Pure monorepo rules with no foreign test frameworks.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["test-tool-scenarios", "run-scenarios", "test-missing-file", "test-path-traversal", "test-bounded-output"]`
  - `:action-dag`:
    1. Create directory `tests/probes/` if needed.
    2. Author `tests/probes/tool_scenarios_test.asl` defining scenarios for missing files, path traversal, empty patterns, and output limits.
    3. Document scenario doctrine in `docs/EXAMPLE_DOCTRINE.md`.
    4. Validate syntax integrity with `./bin/asl check tests/probes/tool_scenarios_test.asl`.
    5. Execute gate `./bin/asl test --strict-falsify tests/probes/tool_scenarios_test.asl`.
- **Gate**:
  ```bash
  ./bin/asl test --strict-falsify tests/probes/tool_scenarios_test.asl
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: test file not found: tests/probes/tool_scenarios_test.asl
  ```
  *(Exit code 1; fails because test file tests/probes/tool_scenarios_test.asl does not exist)*
- **Prerequisites (`depends_on`)**: `["item-2", "item-3"]`
- **What breaks if executed out of order**:
  If Item 4 runs before Items 2 and 3, the scenario test suite will fail immediately when asserting on `asl grep`, `:grep`, `asl callers`, or output truncation bounds, because those features are not yet implemented.
- **File ownership (`owns`)**:
  `["tests/probes/tool_scenarios_test.asl", "docs/EXAMPLE_DOCTRINE.md"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task46702.asl"]`

---

### Item 5: Engine Residency & Process Model Specification (Task46705)
- **Path**: `docs/ENGINE_PROCESS_MODEL.md`, `asl/grammar/protocol-conformance.asn`, `.asl.config.asn`
- **Identity**:
  - `:id`: `"item-5"` / `"Task46705"`
  - `:title`: `"Specify engine residency, working directory resolution, and process lifetime model"`
  - `:kind`: `:architecture`
  - `:lane`: `"engine"`
- **Why**: Task46705, Invariant D81, ADR-0081, and Blocker 3:
  - Tooling behaves differently depending on where the engine runs, yet this runtime contract has never been documented.
  - A formal architectural document `docs/ENGINE_PROCESS_MODEL.md` must state:
    1. Session model (`:session-model`): ephemeral execution vs persistent daemon (`--daemon`, `--serve`).
    2. Root determination (`:root-determination`): how `discovered_ws` is resolved from `.asl.config.asn`, why relative paths are normalized against the workspace root, and how path boundaries prevent escaping.
    3. Process lifetime model (`:process-lifetime`): process start mechanics, watchdog timeout bounds (15m ceiling), output spooling buffers, and behavior when a process outlives a session.
    4. C bootstrap adapter architecture: host engine embedding JavaScriptCore on macOS/POSIX.
  - In `asl/grammar/protocol-conformance.asn`, define the `:engine` protocol contract for host engine compliance.
  - Address Blocker 3 by ensuring the gate tests substantive required section keys (`:session-model`, `:process-lifetime`, `:root-determination`) rather than vacuous file existence.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Establish an architectural reference for engine runtime and process lifecycle, eliminating undefined behavior regarding directory dependence and process lifetimes.
  - `:outcomes`:
    - `docs/ENGINE_PROCESS_MODEL.md` authored with substantive architectural definitions.
    - Protocol contracts updated in `asl/grammar/protocol-conformance.asn` with `:engine`.
    - Zero comments (C1) and zero emojis (C2) strictly maintained.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D34", "D81"]`
  - `:variations`: Pure Markdown specification adhering to ADR-0081.
  - `:failure-modes`: Missing required section keys causing gate failure; drift between `.asl.config.asn` and C runtime.
  - `:additional-requirements`: Must contain valid `:session-model`, `:process-lifetime`, and `:root-determination` sections.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["discovered_ws", "run_evaluator"]`
  - `:action-dag`:
    1. Draft `docs/ENGINE_PROCESS_MODEL.md` with explicit sections for `:session-model`, `:process-lifetime`, and `:root-determination`.
    2. Document JavaScriptCore embedding and workspace root discovery via `discovered_ws`.
    3. Update `asl/grammar/protocol-conformance.asn` with `:engine` protocol contract.
    4. Review `.asl.config.asn` for configuration alignment.
    5. Execute gate command verifying presence of required keys.
- **Gate**:
  ```bash
  grep -q ':session-model' docs/ENGINE_PROCESS_MODEL.md && grep -q ':process-lifetime' docs/ENGINE_PROCESS_MODEL.md && grep -q ':root-determination' docs/ENGINE_PROCESS_MODEL.md
  ```
- **Current Baseline Status & Output**:
  ```text
  grep: docs/ENGINE_PROCESS_MODEL.md: No such file or directory
  ```
  *(Exit code 2; fails because docs/ENGINE_PROCESS_MODEL.md does not exist)*
- **Prerequisites (`depends_on`)**: `["item-1", "item-2", "item-3", "item-4"]`
- **What breaks if executed out of order**:
  If Item 5 runs before Item 4, the process lifetime and spooling bounds documented in the specification will lack empirical validation against the scenario test suite.
- **File ownership (`owns`)**:
  `["docs/ENGINE_PROCESS_MODEL.md", "asl/grammar/protocol-conformance.asn", ".asl.config.asn"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task46705.asl"]`

---

### Item 6: Language Scenario Matrix & Undeclared Language Refusal (Task46706)
- **Path**: `asl/grammar/capabilities.asn`, `intel/src/xref.asl`, `asl/tools/asl.c`, `tests/probes/language_matrix_test.asl`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-6"` / `"Task46706"`
  - `:title`: `"Declare supported languages per tool, implement undeclared language refusal, and execute language matrix"`
  - `:kind`: `:tooling`
  - `:lane`: `"coverage"`
- **Why**: Task46706, Invariant D81, ADR-0081, and Blocker 1:
  - Tools are used against whatever languages a repository holds; a tool correct on ASL but silently failing on another base language degrades invisibly.
  - In `asl/grammar/capabilities.asn`, each tool must declare the base languages it supports via `:supportedLanguages`.
  - In `intel/src/xref.asl` and `asl/tools/asl.c`, operations (such as `:out` or xref analysis) must refuse undeclared languages naming the language with `:ERR_UNSUPPORTED_LANGUAGE`, rather than attempting to parse them and returning wrong answers or crashing.
  - In `tests/probes/language_matrix_test.asl`, the scenario matrix must run per declared language under `--strict-falsify`, verifying that undeclared extensions produce explicit refusals.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Prevent silent parsing failures across foreign source files by declaring supported base languages and enforcing strict refusal for unsupported languages.
  - `:outcomes`:
    - `:supportedLanguages` declared per tool in `capabilities.asn`.
    - Unrecognized/unsupported extensions produce explicit `:ERR_UNSUPPORTED_LANGUAGE` refusal naming the language.
    - `tests/probes/language_matrix_test.asl` passes under `--strict-falsify`.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
    - Zero comments (C1) and zero emojis (C2) maintained.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Native ASL test forms with non-zero evaluated assertions.
  - `:failure-modes`: Undeclared extension treated as generic text or failing with `:ERR_FILE_NOT_FOUND` instead of language refusal; binary target mismatch.
  - `:additional-requirements`: Must recompile and maintain binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["g_canonical_caps", "extract-docstring-refs", "execute_single_step"]`
  - `:action-dag`:
    1. Declare `:supportedLanguages` for each tool in `asl/grammar/capabilities.asn`.
    2. Add language checking and refusal in `intel/src/xref.asl`.
    3. In `asl/tools/asl.c` (`execute_single_step` for `:out`), add extension validation refusing unsupported extensions with `:ERR_UNSUPPORTED_LANGUAGE` before filesystem access.
    4. Author `tests/probes/language_matrix_test.asl` executing the scenario matrix for declared languages and asserting refusal on unsupported extensions.
    5. Recompile native engine and update `bin/asl`, `asl/bin/asl`, and `asl/asl`.
    6. Execute gate command verifying RPC refusal on `.xyz` and passing language matrix test.
- **Gate**:
  ```bash
  ./bin/asl rpc '(:batch (:out "test.xyz"))' | grep -q ':ERR_UNSUPPORTED_LANGUAGE' && ./bin/asl test --strict-falsify tests/probes/language_matrix_test.asl
  ```
- **Current Baseline Status & Output**:
  ```text
  (:batch-res :status "failed" :items-count 1 :failed-count 1 :parallel true :results [
    (:step :id 1 :op "out" :status "rejected" :error-code ":ERR_FILE_NOT_FOUND" :message "File not found: test.xyz")
  ])
  ```
  *(Exit code 1; fails because baseline returns :ERR_FILE_NOT_FOUND instead of :ERR_UNSUPPORTED_LANGUAGE, and tests/probes/language_matrix_test.asl does not exist)*
- **Prerequisites (`depends_on`)**: `["item-4", "item-5"]`
- **What breaks if executed out of order**:
  If Item 6 runs before Item 4 and Item 5, the language matrix runner will lack the core scenario fixtures from Item 4 and the process/runtime model from Item 5, causing testing discrepancies.
- **File ownership (`owns`)**:
  `["asl/grammar/capabilities.asn", "intel/src/xref.asl", "asl/tools/asl.c", "tests/probes/language_matrix_test.asl", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task46706.asl"]`

---

## Risks

1. **Line Coordinate for `int main` in `asl/tools/asl.c`**:
   - *Risk*: On the current baseline tree, `int main(int argc, char **argv)` is located at line 6246 (`asl/tools/asl.c:6246`), whereas the prompt gate specifies `./bin/asl grep "int main" asl/tools/asl.c | grep -E -q "(4940|6246|[0-9]+:.*int main)"`. If `asl grep` reports the real 1-indexed line number (6246, or higher after adding Item 1), `grep -E -q "(4940|6246|[0-9]+:.*int main)"` will fail unless 4940 is matched or the check permits the actual line coordinate.
   - *Mitigation*: The gate command is included verbatim as requested. We flag to the implementer and orchestrator that line 6246 is the physical coordinate of `int main`, and recommend matching on the formatted line number structure or line coordinate.

2. **C Bootstrap Adapter Recompilation and Triple Binary Parity**:
   - *Risk*: `asl/tools/asl.c` modifications require compilation with macOS clang and JavaScriptCore (`-framework JavaScriptCore`). Discrepancies between `bin/asl`, `asl/bin/asl`, and `asl/asl` will cause subsequent gates or agent executions to run against stale binaries.
   - *Mitigation*: Every item modifying `asl/tools/asl.c` (Items 1, 2, 3, 6) explicitly includes `["bin/asl", "asl/bin/asl", "asl/asl"]` in `:owns` and relies on `scripts/build_and_install.sh` to synchronize all three binaries atomically.

3. **Strict Falsification Assertion Counts under `--strict-falsify`**:
   - *Risk*: ASL test suites run with `--strict-falsify` will fail if zero assertions are executed or if evaluation terminates early due to an unbound symbol.
   - *Mitigation*: Both `tests/probes/tool_scenarios_test.asl` and `tests/probes/language_matrix_test.asl` are constructed with explicit top-level runner functions containing multiple deterministic `(assert ...)` forms.

4. **Process Output Bounding in `asl-sh`**:
   - *Risk*: Spooling unbounded subprocess stdout/stderr in memory risks runaway heap growth before truncation triggers.
   - *Mitigation*: `asl/packages/asl-sh/src/spool.asl` utilizes a two-tier ring buffer (200 lines in RAM) and circular disk spool (10MB) with `spool-truncate`, ensuring hard memory bounds.

---

## Out of Scope

1. **Acceptance Fixture Authoring (`tests/acceptance/d81/Task467*.asl`)**:
   - Under the Separation of Duties protocol (Invariant D81 and `hiddenTests`), grader fixtures in `tests/acceptance/d81/` and `SuperviseGate.sh` are strictly owned and evaluated by `independentVerifier`. The implementer must not author, edit, or grade their own acceptance fixtures.

2. **Full Cross-Language AST Semantic Resolution**:
   - Item 6 verifies language declarations, scenario matrix execution per declared language, and explicit refusal for undeclared languages. Deep semantic AST resolution for foreign languages (e.g., Python/TypeScript type inference) belongs to compiler/resolver phases and is not part of Phase 467.

3. **Cross-Platform Engine Re-architecture (Linux/Windows V8/Node Host Porting)**:
   - `docs/ENGINE_PROCESS_MODEL.md` in Item 5 documents the engine architecture and cross-platform host contracts. Porting the C bootstrap adapter from macOS JavaScriptCore to Linux/Windows runtimes is out of scope for Phase 467.

---

## Opportunities & Suggestions

1. **Structured Output Serialization Flag (`--format=asn` / `--format=json`)**:
   - Subcommands `asl inventory`, `asl callers`, `asl impact`, and `asl grep` currently format output for terminal reading. Adding a `--format=asn` flag in a subsequent phase will allow autonomous agents to ingest S-expressions directly without wrapping calls in `asl rpc`.

2. **Ripgrep Engine Acceleration Hook**:
   - While pure C content search satisfies self-contained engine requirements, future phases could inspect whether host `rg` is available and delegate ultra-large workspace scans when available, falling back to resident C scan.

3. **Automated Capability Sync Hook**:
   - Modifying or adding capabilities in `asl/tools/asl.c` and `asl/grammar/capabilities.asn` could be automatically checked via a pre-commit or gate audit rule to guarantee zero manual drift across documentation and engine registries.
