# Phase 8: Verification Layer Honesty & Static Analysis Toolchain (Причёсывание репозиториев)

## Acceptance Criteria
1. **Invariant D81 & Task45501 (CLI Test Argument Honesty)**:
   - In `asl/tools/asl.c`:
     When `asl test` is invoked with no file arguments (`argc < 3`), print usage to stderr and exit with code 1 instead of returning a silent zero:
     ```c
     if (argc >= 2 && strcmp(argv[1], "test") == 0) {
         if (argc < 3) {
             fprintf(stderr, "Usage: asl test [options] <files...>\n");
             return 1;
         }
     ```
   - Invocations of `./bin/asl test` with no arguments exit with code 1 and output `Usage: asl test` to stderr.
2. **Invariants C3, D34, D81 & Tasks 45701, 45702, 45703 (Static Analysis Subcommands: bind, dup, dead)**:
   - In `asl/tools/asl.c`:
     Implement subcommands in `asl audit`:
     - `asl audit bind`: audits module imports across all `.asl` files and verifies resolution.
     - `asl audit dup`: audits duplicate function definitions across packages against declared ownership boundaries.
     - `asl audit dead`: audits unreachable modules and unreferenced definitions.
     - Update usage string in `asl/tools/asl.c:4164` to `Usage: asl audit <consistency|gates|bind|dup|dead>`.
   - Each subcommand executes with exit code 0 on the clean workspace tree and outputs clean audit receipts with checkmarks (`"✓"`).
3. **Invariant D81 & Task47303 (Binary Parity & Distribution Reconciliation)**:
   - Recompile `bin/asl` from `asl/tools/asl.c` and replicate to `asl/bin/asl` and `asl/asl`.
   - All three engine binaries (`bin/asl`, `asl/bin/asl`, `asl/asl`) are byte-identical and report matching SHA-256 digests.
4. **Phase Gate Certification (Master Verification)**:
   - Master verification pre-checks confirm all Phase 8 work item contracts are fulfilled.
   - Master gate execution `./bin/asl gate` passes all 7 verification tiers cleanly (covering 313 test suites, 8587 evaluated assertions, zero foreign files, pure monorepo boundary).
   - Sovereign consistency audit `./bin/asl audit consistency` passes with 0 defects across all 5 epistemic dimensions.

---

## Ordered Work Items

### Item 1: CLI Test Argument Honesty (Task45501)
- **Path**: `asl/tools/asl.c:4205-4262`
- **Identity**:
  - `:id`: `"item-1"` / `"Task45501"`
  - `:title`: `"CLI Test Argument Honesty: asl test with no file arguments exits 1 with usage error"`
  - `:kind`: `:engine`
  - `:lane`: `"honesty"`
- **Why**: Invariant D81, ADR-0081, and Task45501:
  - `asl/tools/asl.c:4205-4262` handles `asl test`. When `argc < 3` (e.g. `./bin/asl test`), line 4246 currently branches into an `else` clause that runs `scripts/run-gate-tests.sh` which executes test suites and exits with status 0. The runner produces a silent zero exit without the caller having specified any test files.
  - An invocation with no path must exit non-zero stating that it will not run without a target. Silence with exit 0 is a defective outcome that masks missing test arguments in scripts and CI pipelines.
  - When `asl test` is invoked with `argc < 3`, print `Usage: asl test [options] <files...>\n` to stderr and exit with code 1.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Ensure `asl test` enforces positional arguments and refuses empty invocations with a usage error and non-zero exit code.
  - `:outcomes`: `["asl test with no file arguments exits 1", "Usage error printed to stderr", "Silent zero exit on empty invocation eliminated"]`
- **Constraints & Contingencies**:
  - `:invariants`: `["D81"]`
  - `:variations`: Matches existing CLI argument validation conventions in `asl/tools/asl.c:4176-4179` (`asl check`) and `asl/tools/asl.c:4191-4194` (`asl lint`).
  - `:failure-modes`: Flag-only invocations (e.g. `asl test --strict-falsify`) must not bypass target requirements.
  - `:additional-requirements`: Must compile cleanly under macOS `clang -O2 -framework JavaScriptCore`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`: `["Inspect test CLI dispatch in asl.c", "Insert argc < 3 validation guard printing usage to stderr", "Recompile bin/asl", "Execute Item 1 gate"]`
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys
  res = subprocess.run(["./bin/asl", "test"], capture_output=True, text=True)
  if res.returncode == 0:
      print("Error: asl test with no args returned silent zero")
      sys.exit(1)
  if "Usage: asl test" not in res.stderr and "Usage: asl test" not in res.stdout:
      print("Error: asl test with no args did not output usage error")
      sys.exit(1)
  print("Item 1 passed: asl test refuses empty invocation with non-zero exit")
  '
  ```
- **Current Baseline Failure**:
  ```text
  Error: asl test with no args returned silent zero
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/tools/asl.c"]`
- **What breaks if run before prerequisite**: None (Item 1 is the foundational CLI honesty unit).

---

### Item 2: Static Analysis Subcommands: bind, dup, dead (Task45701, Task45702, Task45703)
- **Path**: `asl/tools/asl.c:4158-4167`
- **Identity**:
  - `:id`: `"item-2"` / `"Task45701-45703"`
  - `:title`: `"Static Analysis Toolchain: implement asl audit bind, dup, and dead subcommands"`
  - `:kind`: `:tooling`
  - `:lane`: `"staticAnalysis"`
- **Why**: Invariants C3, D34, D81, ADR-0081, and Tasks 45701, 45702, 45703:
  - **Task45701 (`asl audit bind`)**: Monorepo module imports and binding graphs currently lack an automated CLI audit command; unresolvable imports remain latent until execution. `asl audit bind` scans module imports across all `.asl` files and verifies resolution against known modules.
  - **Task45702 (`asl audit dup`)**: Invariants C3 and D34 assign canonical symbol ownership across foundational packages. `asl audit dup` audits duplicate function definitions across packages against declared package ownership boundaries.
  - **Task45703 (`asl audit dead`)**: Dead definitions, constant stubs, and unreachable modules pass basic syntactic checks unnoticed. `asl audit dead` audits unreachable modules and unreferenced definitions across the codebase.
  - In `asl/tools/asl.c:4158-4167`, `asl audit` currently only recognises `consistency` and `gates`, rejecting any other subcommand with `Usage: asl audit <consistency|gates>`.
  - Wire `bind`, `dup`, and `dead` into `asl audit` dispatch and update usage string in `asl/tools/asl.c:4164` to `Usage: asl audit <consistency|gates|bind|dup|dead>`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Implement first-class static analysis commands directly in the native ASL engine CLI.
  - `:outcomes`:
    - `["asl audit bind validates module import resolution across all .asl files"]`
    - `["asl audit dup validates duplicate function definitions against package boundaries"]`
    - `["asl audit dead validates unreachable modules and unreferenced definitions"]`
    - `["Usage string updated to: Usage: asl audit <consistency|gates|bind|dup|dead>"]`
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C3", "D34", "D81"]`
  - `:variations`: Implement static analysis commands utilizing `collect_tree_files(ws_root, "", ".asl", NULL, ...)` and file parsing functions in `asl.c`.
  - `:failure-modes`: False positives on justified local duplicate implementations; ensure package boundaries and standard library paths are correctly classified.
  - `:additional-requirements`: Must return exit code 0 on the clean monorepo tree and emit receipts with `"✓"`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Implement static analysis audit handlers in `asl/tools/asl.c`: `run_cmd_audit_bind`, `run_cmd_audit_dup`, `run_cmd_audit_dead`.
    2. Wire handlers into `asl audit` dispatch block at `asl/tools/asl.c:4158-4167`.
    3. Update usage string to `Usage: asl audit <consistency|gates|bind|dup|dead>`.
    4. Compile `bin/asl` and run Item 2 gate.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys
  for sub in ["bind", "dup", "dead"]:
      res = subprocess.run(["./bin/asl", "audit", sub], capture_output=True, text=True)
      if res.returncode != 0:
          print(f"Error: asl audit {sub} failed: {res.stderr}\n{res.stdout}")
          sys.exit(1)
      if "✓" not in res.stdout and "audited" not in res.stdout.lower() and "passed" not in res.stdout.lower():
          print(f"Error: asl audit {sub} did not return clean audit receipt: {res.stdout}")
          sys.exit(1)
  print("Item 2 passed: all three static analysis audit subcommands passed cleanly")
  '
  ```
- **Current Baseline Failure**:
  ```text
  Error: asl audit bind failed: 
  Usage: asl audit <consistency|gates>
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `["asl/tools/asl.c"]`
- **What breaks if run before prerequisite**: Modifying `asl/tools/asl.c` out of sequence risks merge conflicts or leaving `asl test` empty invocation dishonesty unaddressed.

---

### Item 3: Binary Parity & Distribution Reconciliation (Task47303)
- **Path**: `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-3"` / `"Task47303"`
  - `:title`: `"Binary Parity & Distribution Reconciliation: synchronize bin/asl, asl/bin/asl, and asl/asl"`
  - `:kind`: `:release`
  - `:lane`: `"distribution"`
- **Why**: Invariant D81, ADR-0081, and Task47303:
  - Following modifications to `asl/tools/asl.c` in Item 1 and Item 2, compiling only `bin/asl` causes binary divergence with replica binaries `asl/bin/asl` and `asl/asl`.
  - Different agent toolbelts, test runners, and system symlinks invoke either `bin/asl`, `asl/bin/asl`, or `asl/asl`. Recompiling `bin/asl` and replicating to `asl/bin/asl` and `asl/asl` guarantees 100% byte parity and identical SHA-256 digests across all distributions.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Ensure all three engine binary distributions are freshly built from updated source and share identical SHA-256 hashes.
  - `:outcomes`: `["bin/asl, asl/bin/asl, and asl/asl share identical SHA-256 digests", "All binary replicas reflect Item 1 and Item 2 capabilities"]`
- **Constraints & Contingencies**:
  - `:invariants`: `["D81"]`
  - `:variations`: Recompilation follows `scripts/build_and_install.sh:22-31` (`clang -O2 -framework JavaScriptCore -o bin/asl asl/tools/asl.c && cp -f bin/asl asl/bin/asl && cp -f bin/asl asl/asl`).
  - `:failure-modes`: Binary write permissions or target locking during build.
  - `:additional-requirements`: All replicated binaries must retain executable permissions (`chmod +x`).
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Compile `bin/asl` from `asl/tools/asl.c` via `clang -O2 -framework JavaScriptCore`.
    2. Replicate `bin/asl` to `asl/bin/asl` and `asl/asl`.
    3. Ensure executable permissions across all targets.
    4. Execute Item 3 gate.
- **Gate**:
  ```bash
  python3 -c '
  import hashlib, sys
  h1 = hashlib.sha256(open("bin/asl", "rb").read()).hexdigest()
  h2 = hashlib.sha256(open("asl/bin/asl", "rb").read()).hexdigest()
  h3 = hashlib.sha256(open("asl/asl", "rb").read()).hexdigest()
  if not (h1 == h2 == h3):
      print(f"Error: binary divergence h1={h1[:8]}, h2={h2[:8]}, h3={h3[:8]}")
      sys.exit(1)
  print("Item 3 passed: all binaries are reconciled and identical")
  '
  ```
- **Current Baseline Failure**:
  When Item 1 and Item 2 modify `asl/tools/asl.c` and compile `bin/asl`, `asl/bin/asl` and `asl/asl` diverge (`h1 != h2 != h3`), producing:
  ```text
  Error: binary divergence h1=..., h2=16df4d89, h3=16df4d89
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1", "item-2"]`
- **File ownership (`owns`)**: `["bin/asl", "asl/bin/asl", "asl/asl"]`
- **What breaks if run before prerequisite**: Reconciling binaries before modifying `asl/tools/asl.c` in Item 1 and Item 2 would require another reconciliation pass after those items compile, leaving the replicas stale in the interim.

---

### Item 4: Master Verification (Full Gate & Consistency Audit)
- **Path**: Full monorepo verification harness
- **Identity**:
  - `:id`: `"item-4"` / `"Phase8MasterVerification"`
  - `:title`: `"Master Verification: all 7 gates and 5 consistency dimensions passed cleanly"`
  - `:kind`: `:verification`
  - `:lane`: `"verification"`
- **Why**:
  - Validates that all Phase 8 implementations (CLI test argument honesty, static analysis subcommands `bind`, `dup`, `dead`, and engine binary parity) integrate cleanly without regressing any of the monorepo's existing 7 verification tiers (313 test suites, 8587 evaluated assertions, pure monorepo boundary) or 5 consistency dimensions.
  - Verifies that `./bin/asl gate` and `./bin/asl audit consistency` pass cleanly with zero errors.
- **Context & Intent**:
  - `:context`: `D81PlanContext`, `D52`
  - `:purpose`: End-to-end verification of repository integrity under Phase 8 toolchain updates.
  - `:outcomes`:
    - `["Verification pre-checks confirm Items 1-3 complete"]`
    - `["./bin/asl gate passes all 7 verification tiers cleanly"]`
    - `["./bin/asl audit consistency passes all 5 epistemic dimensions with 0 defects"]`
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D34", "D52", "D81"]`
  - `:variations`: None.
  - `:failure-modes`: Regression in Gate 5 assertions, ASN ledger syntax errors, or broken ADR bidirectional links.
  - `:additional-requirements`: Must complete with exit code 0.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Execute composite verification pre-check covering Items 1, 2, and 3.
    2. Execute `./bin/asl gate`.
    3. Execute `./bin/asl audit consistency`.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys
  # Verify Item 1: asl test honesty
  res = subprocess.run(["./bin/asl", "test"], capture_output=True, text=True)
  if res.returncode == 0 or ("Usage: asl test" not in res.stderr and "Usage: asl test" not in res.stdout):
      sys.exit("Item 1 incomplete: asl test did not refuse empty invocation")

  # Verify Item 2: static analysis subcommands
  for sub in ["bind", "dup", "dead"]:
      res = subprocess.run(["./bin/asl", "audit", sub], capture_output=True, text=True)
      if res.returncode != 0 or ("✓" not in res.stdout and "audited" not in res.stdout.lower() and "passed" not in res.stdout.lower()):
          sys.exit(f"Item 2 incomplete: asl audit {sub} failed")

  # Verify Item 3: binary reconciliation
  import hashlib
  h1 = hashlib.sha256(open("bin/asl", "rb").read()).hexdigest()
  h2 = hashlib.sha256(open("asl/bin/asl", "rb").read()).hexdigest()
  h3 = hashlib.sha256(open("asl/asl", "rb").read()).hexdigest()
  if not (h1 == h2 == h3):
      sys.exit(f"Item 3 incomplete: binary divergence bin/asl={h1[:8]}, asl/bin/asl={h2[:8]}, asl/asl={h3[:8]}")

  print("Master verification pre-checks passed cleanly")
  ' && ./bin/asl gate && ./bin/asl audit consistency
  ```
- **Current Baseline Failure**:
  ```text
  Item 1 incomplete: asl test did not refuse empty invocation
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1", "item-2", "item-3"]`
- **File ownership (`owns`)**: `[]`
- **What breaks if run before prerequisite**: Fails immediately because Items 1, 2, and 3 have not been applied on the baseline tree.

---

## Risks
1. **Host Compilation Flags**:
   `asl/tools/asl.c` requires linking with `-framework JavaScriptCore` on macOS (`clang -O2 -framework JavaScriptCore -o bin/asl asl/tools/asl.c`). Invocations of `clang` omitting this flag will fail with unresolved symbol errors during linking.
2. **Static Analysis Traversal Performance**:
   Scanning the monorepo's 904+ `.asl` files for `bind`, `dup`, and `dead` audits requires careful file I/O and memory management to prevent memory exhaustion or slow execution. Reusing existing `read_file_alloc` and `collect_tree_files` functions ensures bounded resource usage.
3. **Execution Time of Gate 5**:
   Gate 5 executes all 313 native test suites across the monorepo via `scripts/run-gate-tests.sh` (~6-8 seconds). The master gate execution must allow sufficient execution time.

---

## Out of Scope
1. **Benchmarking & Token Research**:
   Explicitly excluded per orchestrator directive.
2. **Compiler Self-Hosting Rewrites**:
   Rewriting the native C bootstrap adapter `asl/tools/asl.c` into pure AgentScript is tracked under future compiler self-hosting phases and is outside Phase 8 scope.
3. **Automated Inventory Ratchet and Seeded Fixtures (Task45704, Task45705)**:
   Emitting `.asl/mem/telemetry` historical snapshots and fixture seeding for every defect class are part of subsequent Wave 104 tasks. Phase 8 focuses strictly on CLI honesty (`asl test` honesty), static analysis subcommands (`bind`, `dup`, `dead`), binary reconciliation, and gate integrity.
4. **Strict-Falsify Flag Removal or Logic Rework (Task45502)**:
   Reworking `--strict-falsify` across test scripts and rules is tracked under Task45502.

---

## Opportunities & Suggestions
1. **Integration into Verification Gate Tiers**:
   Integrate `asl audit bind`, `dup`, and `dead` directly into a dedicated Gate Tier (e.g. Tier 8: Static Analysis Integrity) within `./bin/asl gate` once stabilized.
2. **Machine-Readable Audit Receipts**:
   Support `--format asn` or `--format json` for `asl audit <bind|dup|dead>` to enable direct ingestion of static analysis diagnostics by autonomous agent harnesses (`asl-lens`, `asl-intel`).
3. **Automated Pre-Commit Binary Check**:
   Add a pre-commit check verifying SHA-256 identity between `bin/asl`, `asl/bin/asl`, and `asl/asl` to prevent accidental divergence during development.
