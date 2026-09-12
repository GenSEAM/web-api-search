# Phase 471: Closing the Unplanned

## Acceptance Criteria
1. **Repository Plan Verification Command (Task47101)**:
   - Implement `asl audit plan` in `asl/tools/asl.c`.
   - Structural checks performed by the repository binary rather than ephemeral session scratchpads:
     - DAG cycle detection across all tasks in `.asl/mem/tasks/*.asn`.
     - Completeness of mandatory D52 fields (`:id`, `:phase`, `:title`, `:owns`, `:gate`).
     - Dangling dependency detection (tasks depending on non-existent task IDs).
     - Unregistered task detection (tasks missing from ADRs and intent ledger).
   - Binary parity maintained across `bin/asl`, `asl/bin/asl`, and `asl/asl` with identical SHA-256 digests.
   - Acceptance fixture `tests/acceptance/d81/Task47101.asl` is owned and evaluated by `independentVerifier` via `sh tests/acceptance/d81/SuperviseGate.sh Task47101`.
2. **Authoring and Scaffolding as a First-Class Agent Path (Task47102)**:
   - Implement `asl scaffold <module|test|fn> <name> [--dry-run]` in `asl/tools/asl.c`.
   - Scaffolds emit syntactically valid forms with non-stub assertions (never emitting constant-returning bodies).
   - Activate staged editing operations in resident RPC (`:patch`, `:diff`, `:flush`, `:discard`) and update `probe_stagedEdit` in `asl/tools/asl.c:4841` to return `CAP_STATUS_WORKS`.
   - Update `asl/grammar/rpc.asn:102-108` staging operation registry from `:status :unsupported` to active.
   - Binary parity maintained across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
   - Acceptance fixture `tests/acceptance/d81/Task47102.asl` is owned and evaluated by `independentVerifier` via `sh tests/acceptance/d81/SuperviseGate.sh Task47102`.
3. **Dependency Ledger Truth & Boundary Classification (Task47103)**:
   - Remove retired `python3` entry from `.asl/mem/dependencies.asn:28-41`.
   - Distinguish build boundaries (such as C bootstrap `clang`/`gcc` and independent test host `JavaScriptCore`) from runtime substrate requirements in alignment with `asl/grammar/dependency-boundaries.asn`.
   - Delimiter balance and ASN syntax verified cleanly via `./bin/asl check .asl/mem/dependencies.asn`.
   - Acceptance fixture `tests/acceptance/d81/Task47103.asl` is owned and evaluated by `independentVerifier` via `sh tests/acceptance/d81/SuperviseGate.sh Task47103`.

---

## Ordered Work Items

### Item 1: Repository Plan Verification Command (Task47101)
- **Path**: `asl/tools/asl.c:3305-3700,5588-5606`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-1"` / `"Task47101"`
  - `:title`: `"The plan is verified by the repository, not by a scratchpad"`
  - `:kind`: `:tooling`
  - `:lane`: `"closure"`
- **Why**: Invariant D81, ADR-0081, and Task47101:
  - Every structural claim made about the plan currently comes from ephemeral session scratchpads: that the DAG is acyclic, that no task is missing a D52 field, that every task is registered in ADR and intent ledgers, and that writer pairs are ordered.
  - None of those checks is in the repository binary. In `asl/tools/asl.c:5603`, invoking `./bin/asl audit plan` prints `Usage: asl audit <consistency|gates|bind|dup|dead|doctor>` and exits with code 1.
  - In `asl/tools/asl.c:3407`, `run_cmd_consistency` only validates D52 fields for `task-401` tasks rather than all active phase collections.
  - Implement `asl audit plan` in `asl/tools/asl.c`:
    1. Scan all `.asl/mem/tasks/*.asn` task collections.
    2. Enforce D52 field completeness across all phase tasks: `:id`, `:phase`, `:title`, `:owns`, `:gate` (and enriched fields `:motivation`, `:purpose`, `:context`, `:outcomes`, `:invariants`, `:variations`, `:adr`, `:decision`).
    3. Construct the full task dependency DAG from `:dependsOn` / `:depends-on` declarations and detect any directed cycles, reporting cycle paths explicitly.
    4. Detect dangling dependencies: tasks depending on non-existent task IDs.
    5. Detect unregistered tasks: tasks not referenced in ADRs (`.asl/mem/decisions/*.asn`) or intent ledger (`.asl/mem/intent.asn`).
  - Recompile `bin/asl` and synchronize with `asl/bin/asl` and `asl/asl` to maintain identical SHA-256 digests.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Embed plan and DAG verification directly into the native repository binary so plan validation is fully reproducible, falsifiable, and automated.
  - `:outcomes`:
    - `asl audit plan` subcommand implemented and routed in `asl/tools/asl.c`.
    - Dependency cycle detection across all tasks implemented.
    - Mandatory D52 field validation implemented across all active tasks.
    - Dangling dependency detection and unregistered task detection implemented.
    - Binary parity maintained across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D52", "D81"]`
  - `:variations`: Can be invoked either as `asl audit plan` or integrated into `asl audit consistency` / `asl check plan`.
  - `:failure-modes`: Recursion stack overflow on large circular graphs; false positive on non-phase backlog files.
  - `:additional-requirements`: Must preserve binary parity across all 3 binary locations (`bin/asl`, `asl/bin/asl`, `asl/asl`).
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["run_cmd_audit_plan", "detect_dag_cycles", "validate_d52_fields"]`
  - `:action-dag`:
    1. Implement plan scanning and task collection parsing in `asl/tools/asl.c`.
    2. Add cycle detection algorithm over task `:dependsOn` graph.
    3. Add validation for required D52 fields (`:id`, `:phase`, `:title`, `:owns`, `:gate`, etc.).
    4. Route `plan` subcommand under `asl audit` in `asl/tools/asl.c:5589-5606`.
    5. Recompile `bin/asl` and duplicate to `asl/bin/asl` and `asl/asl`.
    6. Execute gate `./bin/asl audit plan`.
- **Gate**:
  ```bash
  ./bin/asl audit plan
  ```
- **Current Baseline Failure**:
  ```text
  Usage: asl audit <consistency|gates|bind|dup|dead|doctor>
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task47101.asl"]` (owned strictly by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: None (Item 1 is the baseline foundation for plan verification).

---

### Item 2: First-Class Agent Scaffolding & Staged Editing (Task47102)
- **Path**: `asl/tools/asl.c:1116-1121,4841-4845,5580-5640`, `asl/grammar/rpc.asn:102-108`, `mem/src/structural_editor.asl:1-167`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-2"` / `"Task47102"`
  - `:title`: `"Authoring and scaffolding as a first class agent path"`
  - `:kind`: `:tooling`
  - `:lane`: `"closure"`
- **Why**: Invariant D81, ADR-0081, and Task47102:
  - Agents currently author code by writing whole files or making raw text edits with minimal syntax safety, and staging operations in RPC (`:diff`, `:flush`, `:discard`) are explicitly disabled (`:ERR_UNSUPPORTED` at `asl/tools/asl.c:1116-1121` and `probe_stagedEdit` returning `CAP_STATUS_LIES` at `asl/tools/asl.c:4844`).
  - In `asl/grammar/rpc.asn:102-108`, staging operations are listed with `:status :unsupported`.
  - Invoking `./bin/asl scaffold module sample_mod --dry-run` fails with `Error: unrecognized subcommand 'scaffold'`.
  - Implement `asl scaffold <module|test|fn> <name> [--dry-run]` in `asl/tools/asl.c`:
    1. `asl scaffold module <name>` emits a well-formed ASL module with declaration, export vector, imports, and a non-stub entry point function.
    2. `asl scaffold test <name>` emits a well-formed test suite importing the target and asserting non-trivial behavior (not a stub `assert true` or constant return).
    3. `asl scaffold fn <name>` emits a typed function signature and body with parameter bindings.
    4. When `--dry-run` is specified, output is printed to stdout without writing to disk.
  - Implement staged editing operations in batch RPC:
    1. Support in-memory buffer staging (`:patch`, `:diff`, `:flush`, `:discard`) connecting `asl/tools/asl.c` to `mem/src/structural_editor.asl` and VFS.
    2. Update `asl/grammar/rpc.asn:102-108` from `:status :unsupported` to active.
    3. Update `probe_stagedEdit` in `asl/tools/asl.c:4841-4845` to return `CAP_STATUS_WORKS`.
  - Recompile `bin/asl` and synchronize with `asl/bin/asl` and `asl/asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Provide native CLI scaffolding that emits syntactically valid forms with non-stub assertions, and activate in-memory staged editing operations.
  - `:outcomes`:
    - `asl scaffold` command supports `module`, `test`, `fn` with `--dry-run`.
    - Generated scaffolds parse, bind, and execute assertions without manual repair.
    - RPC staging operations (`:diff`, `:flush`, `:discard`) active and functional.
    - `asl/grammar/rpc.asn` staging status updated from `:unsupported`.
    - Binary parity maintained across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Scaffolding templates use standard ASL forms with docstrings (`:d`), exports (`:x`), imports (`:i`).
  - `:failure-modes`: Emitted template failing parser balance check; staging buffer memory leak across RPC batches.
  - `:additional-requirements`: Must pass dry-run verification for both module and test scaffolding.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["run_cmd_scaffold", "scaffold_module", "scaffold_test", "scaffold_fn"]`
  - `:action-dag`:
    1. Define scaffolding templates in `asl/tools/asl.c` ensuring non-stub assertion bodies.
    2. Implement `run_cmd_scaffold` handling `module`, `test`, and `fn` subcommands with `--dry-run` flag.
    3. Wire staged edit buffers in RPC handler (`:diff`, `:flush`, `:discard`) and update `probe_stagedEdit`.
    4. Update `asl/grammar/rpc.asn` `:asl-mem-staging` entry to active.
    5. Recompile `bin/asl` and synchronize to `asl/bin/asl` and `asl/asl`.
    6. Execute gate `./bin/asl scaffold module sample_mod --dry-run && ./bin/asl scaffold test sample_test --dry-run`.
- **Gate**:
  ```bash
  ./bin/asl scaffold module sample_mod --dry-run && ./bin/asl scaffold test sample_test --dry-run
  ```
- **Current Baseline Failure**:
  ```text
  Error: unrecognized subcommand 'scaffold'
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `["asl/tools/asl.c", "asl/grammar/rpc.asn", "mem/src/structural_editor.asl", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task47102.asl"]` (owned strictly by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: Editing `asl/tools/asl.c` for scaffolding and staging before plan verification risks introducing unverified task relationships or regressions into the repository audit baseline.

---

### Item 3: Dependency Ledger Truth & Boundary Classification (Task47103)
- **Path**: `.asl/mem/dependencies.asn:28-41`, `asl/grammar/dependency-boundaries.asn:1-20`
- **Identity**:
  - `:id`: `"item-3"` / `"Task47103"`
  - `:title`: `"The dependency ledger says what is actually required"`
  - `:kind`: `:remediation`
  - `:lane`: `"closure"`
- **Why**: Invariant D81, ADR-0081, and Task47103:
  - `python3` remains declared at `.asl/mem/dependencies.asn:28-41` despite being completely purged from the codebase during Phase 436. The declaration has outlived the actual dependency.
  - A dependency ledger listing retired dependencies corrupts portability decisions and violates ledger truth.
  - Remove the retired `python3` dependency block from `.asl/mem/dependencies.asn`.
  - Reconcile declared build boundaries (such as C bootstrap compiler `clang`/`gcc` and independent test host `JavaScriptCore` declared in `asl/grammar/dependency-boundaries.asn:6-18`) so they are clearly distinguished from runtime substrate requirements in `.asl/mem/dependencies.asn`.
  - Verify syntax and delimiter balance of `.asl/mem/dependencies.asn` via `./bin/asl check`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Establish absolute truth in the dependency ledger by removing obsolete entries and distinguishing build boundaries from runtime dependencies.
  - `:outcomes`:
    - `python3` entry completely removed from `.asl/mem/dependencies.asn`.
    - Build boundary tiers in `asl/grammar/dependency-boundaries.asn` aligned with dependency registry.
    - Zero syntax or delimiter errors verified via `./bin/asl check`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D34", "D81"]`
  - `:variations`: Dependency entries maintain canonical schema: `:name`, `:type`, `:version`, `:cluster`, `:license`, `:rationale`, `:risk`, `:actionPlan`.
  - `:failure-modes`: Delimiter unbalance when deleting S-expression block; accidental removal of active dependencies (`git`, `bash`).
  - `:additional-requirements`: Must satisfy `! grep -q 'name "python3"' .asl/mem/dependencies.asn` and pass `./bin/asl check .asl/mem/dependencies.asn`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Remove the `(:dependency :name "python3" ...)` block from `.asl/mem/dependencies.asn`.
    2. Ensure build boundary references in `.asl/mem/dependencies.asn` align with `asl/grammar/dependency-boundaries.asn`.
    3. Run delimiter check `./bin/asl check .asl/mem/dependencies.asn`.
    4. Execute gate `! grep -q 'name "python3"' .asl/mem/dependencies.asn && ./bin/asl check .asl/mem/dependencies.asn`.
- **Gate**:
  ```bash
  ! grep -q 'name "python3"' .asl/mem/dependencies.asn && ./bin/asl check .asl/mem/dependencies.asn
  ```
- **Current Baseline Failure**:
  ```text
  (no output)
  ```
  *(Exit code 1; grep finds 'name "python3"' at .asl/mem/dependencies.asn:29, causing the negated test to fail)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `[".asl/mem/dependencies.asn", "asl/grammar/dependency-boundaries.asn"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task47103.asl"]` (owned strictly by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: If the dependency ledger is cleaned without plan verification in place, ledger desynchronization cannot be caught automatically by repository tooling.

---

## Risks
1. **Binary Parity and Distribution Drift**:
   Modifications to `asl/tools/asl.c` in Item 1 and Item 2 require recompiling `bin/asl` and replicating to `asl/bin/asl` and `asl/asl`. Divergence in binary hashes will fail Gate 4/7 during `bin/asl audit gates`.
2. **Plan Cycle False Positives**:
   Tasks with mutual references or cross-collection dependencies must be handled accurately by DAG cycle detection without misinterpreting parallel independent tasks as cycles.
3. **Strict D52 Field Enforcement Scope**:
   When validating D52 completeness across all task collections, legacy or backlog files (e.g. `backlog.asn`) must be scoped appropriately so active phase tasks are strictly enforced without failing on un-migrated historical backlog entries.
4. **Delimiter Balance During ASN Deletion**:
   Removing the `python3` S-expression block from `.asl/mem/dependencies.asn` must preserve enclosing list `(:dependencies [...])` parentheses to prevent delimiter errors.

---

## Out of Scope
1. **Self-Hosting Compiler Rebuild**:
   Rewriting `asl.c` into pure self-hosted ASL is tracked under Phase 438/440.
2. **Subsystem Test Suite Rebinding (Phase 454 / Phase 443)**:
   Remediating external dead suites across browser-plugin, harness, or voice is tracked under Phase 443/444 and Phase 454.
3. **Acceptance Fixture Authorship**:
   Authoring `tests/acceptance/d81/Task47101.asl`, `Task47102.asl`, and `Task47103.asl` is strictly reserved for `independentVerifier`.

---

## Opportunities & Suggestions
1. **Automated Pre-Commit Hook for Plan Audit**:
   Integrate `asl audit plan` into git pre-commit hooks to prevent committing tasks with broken D52 fields or DAG cycles.
2. **Interactive Scaffold Wizard**:
   Support an interactive wizard mode (`asl scaffold --interactive`) that prompts for module name, exports, and imports in terminal environments.
3. **Visual DAG Graphviz Export**:
   Add `--dot` flag to `asl audit plan` to emit a Graphviz DOT representation of task dependency graphs for visual topology inspection.
