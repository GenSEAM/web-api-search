# Phase 9: Instruction Truth & Capability Doctor

## Acceptance Criteria
1. **Invariant D81 & Task46403 (Capability Doctor & Capabilities Lock)**:
   - In `asl/tools/asl.c`:
     Implement `asl doctor` subcommand:
     - Probes declared capabilities against real execution (e.g. `:sym`, `:find`, `:grep`, `:read`, `:out`, `:callers`, `:impact`, `asl check`, `asl test`, `asl audit`, etc.).
     - Measures their actual status across the four closed vocabulary categories: `:works`, `:partial`, `:absent`, `:lies`.
     - Prints a formatted audit receipt to stdout with `"capabilities"` and `"measured"`.
     - Generates and writes `asl/grammar/capabilities.lock` in pure ASN format (`(:capabilities-lock ... :measured ...)`), conforming to invariants C1 (zero comments) and C2 (zero emojis).
   - Invocations of `./bin/asl doctor` exit with code 0, produce a valid receipt, and `./bin/asl check asl/grammar/capabilities.lock` confirms structural validity.
2. **Invariant D81 & Task46401 (Instruction Surface Truth)**:
   - In documentation and instruction surfaces (`AGENTS.md`, `CLAUDE.md`, `README.md`):
     - Ensure surfaces accurately declare available native commands (`asl rpc`, `asl check`, `asl lint`, `asl test`, `asl audit`, `asl doctor`, `asl gate`).
     - Eliminate naked instructions to invoke non-existent CLI subcommands (`asl doc`, `asl task spawn`, `asl task claim`, `asl task recover`, `asl task settle`), reconciling them to reference ASN task documents or native S-expression ops rather than fictional CLI subcommands.
3. **Invariant D81 & Task47303 (Binary Parity & Distribution Reconciliation)**:
   - Recompile `bin/asl` from `asl/tools/asl.c` and replicate to `asl/bin/asl` and `asl/asl`.
   - All three engine binaries (`bin/asl`, `asl/bin/asl`, `asl/asl`) are byte-identical and share matching SHA-256 digests.
   - All three binary paths successfully execute the new `doctor` subcommand (`./<bin> doctor`).
4. **Phase Gate Certification (Master Verification)**:
   - Master verification pre-checks confirm all Phase 9 work item contracts are fulfilled.
   - Master gate execution `./bin/asl gate` passes all 7 verification tiers cleanly (manifests, form balance, site claims, zero foreign files, 313 test suites with 8587 assertions, token density, modular skills).
   - Sovereign consistency audit `./bin/asl audit consistency` passes with 0 defects across all 5 epistemic dimensions.

---

## Ordered Work Items

### Item 1: Capability Doctor & Capabilities Lock (Task46403)
- **Path**: `asl/tools/asl.c:4738-4770`, `asl/grammar/capabilities.lock`
- **Identity**:
  - `:id`: `"item-1"` / `"Task46403"`
  - `:title`: `"Capability Doctor: implement asl doctor subcommand and generate capabilities.lock"`
  - `:kind`: `:tooling`
  - `:lane`: `"instructionTruth"`
- **Why**: Invariant D81, ADR-0081, and Task46403:
  - The capabilities rule in `asl/grammar/rules.asn:67-70` states:
    `:why "measured, not declared: :status is written by asl doctor into capabilities.lock, and a hand-edited status that contradicts measurement fails gate 7"`.
  - However, `asl doctor` does not exist in `asl/tools/asl.c` (currently returning `Error: unrecognized subcommand 'doctor'`), and `asl/grammar/capabilities.lock` does not exist. All 36 statuses in `asl/grammar/capabilities.asn` are hand-written and unmeasured.
  - Implement `asl doctor` subcommand in `asl/tools/asl.c`:
    Probes declared capabilities against real execution (e.g. `:sym`, `:find`, `:grep`, `:read`, `:out`, `:callers`, `:impact`, `asl check`, `asl test`, `asl audit`, etc.), measures their actual status (`:works`, `:partial`, `:absent`, `:lies`), prints a formatted receipt, and writes/updates `asl/grammar/capabilities.lock` in pure ASN format with zero comments (C1) and zero emojis (C2).
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Provide native CLI measurement of declared capabilities against reality and generate `capabilities.lock`.
  - `:outcomes`:
    - `asl doctor` subcommand exists and executes capability probes.
    - Actual status measured across the four canonical categories (`:works`, `:partial`, `:absent`, `:lies`).
    - Writes `asl/grammar/capabilities.lock` formatted as pure ASN with zero comments and zero emojis.
    - Verified by `asl check asl/grammar/capabilities.lock`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Implement capability probing via embedded execution logic in `asl.c` calling internal handlers (`handle_payload`, `run_cmd_consistency`, `check_file_delimiters`) or direct subprocess invocations.
  - `:failure-modes`: False classification of working operations; formatting violations in `capabilities.lock`.
  - `:additional-requirements`: Must be valid ASN passing `./bin/asl check asl/grammar/capabilities.lock`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Implement `run_cmd_doctor` in `asl/tools/asl.c`.
    2. Register `asl doctor` dispatch in `asl/tools/asl.c` subcommand switch.
    3. Execute capability probes against internal operations (`:sym`, `:find`, `:grep`, `:read`, `:out`, `:callers`, `:impact`, `check`, `test`, `audit`).
    4. Format and emit machine-native `asl/grammar/capabilities.lock` S-expression.
    5. Recompile `bin/asl` and run Item 1 gate.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys, os
  res = subprocess.run(["./bin/asl", "doctor"], capture_output=True, text=True)
  if res.returncode != 0:
      print(f"Error: asl doctor failed: {res.stderr}\n{res.stdout}")
      sys.exit(1)
  if "capabilities" not in res.stdout.lower() and "measured" not in res.stdout.lower():
      print("Error: asl doctor output missing receipt")
      sys.exit(1)
  lock = "asl/grammar/capabilities.lock"
  if not os.path.exists(lock):
      print(f"Error: missing lock file {lock}")
      sys.exit(1)
  content = open(lock).read()
  if "(:capabilities-lock" not in content or ":measured" not in content:
      print("Error: invalid capabilities.lock format")
      sys.exit(1)
  print("Item 1 passed: asl doctor measured capabilities and generated lock")
  ' && ./bin/asl check asl/grammar/capabilities.lock
  ```
- **Current Baseline Failure**:
  ```text
  Error: asl doctor failed: Error: unrecognized subcommand 'doctor'
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/tools/asl.c", "asl/grammar/capabilities.lock"]`
- **What breaks if run before prerequisite**: None (Item 1 is the foundational capability measurement unit).

---

### Item 2: Instruction Surface Truth (Task46401)
- **Path**: `AGENTS.md:281-288`, `CLAUDE.md:281-288`, `README.md`
- **Identity**:
  - `:id`: `"item-2"` / `"Task46401"`
  - `:title`: `"Instruction Surface Truth: reconcile documentation with ground truth commands"`
  - `:kind`: `:protocol`
  - `:lane`: `"instructionTruth"`
- **Why**: Invariant D81, ADR-0081, and Task46401:
  - An instruction surface must name only commands that exist.
  - In `AGENTS.md:281-288` and `CLAUDE.md:281-288`, the task lifecycle instructions explicitly cite non-existent CLI subcommands as active:
    - Line 281: `asl task spawn`, `asl task recover`
    - Line 285: `asl task claim`, `asl task recover`
    - Line 288: `asl task settle`
  - Invoking `./bin/asl task spawn` returns `Error: unrecognized subcommand 'task'`.
  - Stating absent commands as active instructions burns agent turns, degrades confidence, and introduces hallucinations.
  - Documentation and instruction surfaces (`AGENTS.md`, `CLAUDE.md`, `README.md`) must accurately declare active available commands (`asl rpc`, `asl check`, `asl lint`, `asl test`, `asl audit`, `asl doctor`, `asl gate`), eliminating naked references to absent subcommands (`asl doc`, `asl task`) or explicitly qualifying them as planned specifications.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Eliminate references to non-existent CLI subcommands across instruction surfaces and bring documentation into 100% alignment with ground truth.
  - `:outcomes`:
    - `AGENTS.md` and `README.md` contain zero naked invocations of absent subcommands (`asl doc`, `asl task spawn`).
    - Task lifecycle references in `AGENTS.md` and `CLAUDE.md` accurately reflect planned status or native S-expression ops (`:task`, `:claim`, `:settle`).
    - Available native commands (`asl rpc`, `asl check`, `asl lint`, `asl test`, `asl audit`, `asl doctor`, `asl gate`) clearly documented.
- **Constraints & Contingencies**:
  - `:invariants`: `["D81", "D46", "D52"]`
  - `:variations`: Maintain the conceptual 6-stage lifecycle while referencing ASN task documents and `asl rpc` operations rather than fictional CLI subcommands.
  - `:failure-modes`: Inadvertently removing required architectural guidance while cleansing dead command references.
  - `:additional-requirements`: Must pass Gate 2 Python truth assertion.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Scan `AGENTS.md`, `CLAUDE.md`, and `README.md` for references to `asl task`, `asl doc`, and non-existent CLI commands.
    2. Reconcile task lifecycle descriptions in `AGENTS.md` and `CLAUDE.md` to reference ASN task documents and `asl rpc` operations rather than naked `asl task` subcommands.
    3. Ensure `asl doctor` is listed among the verified active CLI tools.
    4. Execute Item 2 gate.
- **Gate**:
  ```bash
  python3 -c '
  import sys
  for f in ["AGENTS.md", "README.md"]:
      c = open(f).read()
      # ensure no naked instructions to invoke non-existent CLI subcommands
      if "asl doc " in c or "asl task spawn" in c:
          print(f"Error: absent command cited as active in {f}")
          sys.exit(1)
  print("Item 2 passed: instruction surfaces reflect ground truth")
  '
  ```
- **Current Baseline Failure**:
  ```text
  Error: absent command cited as active in AGENTS.md
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `["AGENTS.md", "CLAUDE.md", "README.md"]`
- **What breaks if run before prerequisite**: Updating instructions before `asl doctor` is compiled and verified in Item 1 would cite an unverified command on the surface.

---

### Item 3: Binary Parity & Distribution Reconciliation
- **Path**: `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-3"` / `"DistributionReconciliation"`
  - `:title`: `"Binary Parity & Distribution Reconciliation: compile and synchronize bin/asl, asl/bin/asl, and asl/asl"`
  - `:kind`: `:release`
  - `:lane`: `"distribution"`
- **Why**: Invariant D81, ADR-0081, and Task47303:
  - Following modifications to `asl/tools/asl.c` in Item 1, compiling only `bin/asl` causes binary divergence with replica engine binaries `asl/bin/asl` and `asl/asl`.
  - Autonomous harnesses, test scripts, and system paths reference `bin/asl`, `asl/bin/asl`, and `asl/asl` interchangeably. Recompiling `bin/asl` from `asl/tools/asl.c` and replicating to `asl/bin/asl` and `asl/asl` guarantees 100% byte parity and identical SHA-256 digests across all distributions, and ensures `asl doctor` executes identically across all three paths.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Ensure all three engine distributions are freshly compiled from updated source and share identical SHA-256 digests.
  - `:outcomes`:
    - `bin/asl`, `asl/bin/asl`, and `asl/asl` share identical SHA-256 digests.
    - All three binaries execute `doctor` cleanly with exit code 0.
- **Constraints & Contingencies**:
  - `:invariants`: `["D81"]`
  - `:variations`: Recompilation follows `scripts/build_and_install.sh` conventions (`clang -O2 -framework JavaScriptCore -o bin/asl asl/tools/asl.c && cp -f bin/asl asl/bin/asl && cp -f bin/asl asl/asl && chmod +x bin/asl asl/bin/asl asl/asl`).
  - `:failure-modes`: Binary write permissions or target locking during build.
  - `:additional-requirements`: All replicated binaries must retain executable permissions (`chmod +x`).
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Compile `bin/asl` from `asl/tools/asl.c` using `clang -O2 -framework JavaScriptCore`.
    2. Replicate `bin/asl` to `asl/bin/asl` and `asl/asl`.
    3. Ensure executable permissions across all three targets.
    4. Execute Item 3 gate.
- **Gate**:
  ```bash
  python3 -c '
  import hashlib, sys, subprocess
  h1 = hashlib.sha256(open("bin/asl", "rb").read()).hexdigest()
  h2 = hashlib.sha256(open("asl/bin/asl", "rb").read()).hexdigest()
  h3 = hashlib.sha256(open("asl/asl", "rb").read()).hexdigest()
  if not (h1 == h2 == h3):
      print(f"Error: binary divergence h1={h1[:8]}, h2={h2[:8]}, h3={h3[:8]}")
      sys.exit(1)
  for b in ["bin/asl", "asl/bin/asl", "asl/asl"]:
      res = subprocess.run([f"./{b}", "doctor"], capture_output=True, text=True)
      if res.returncode != 0:
          print(f"Error: {b} doctor failed")
          sys.exit(1)
  print("Item 3 passed: all binaries reconciled and verified")
  '
  ```
- **Current Baseline Failure**:
  ```text
  Error: bin/asl doctor failed
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `["bin/asl", "asl/bin/asl", "asl/asl"]`
- **What breaks if run before prerequisite**: Reconciling binaries before implementing `asl doctor` in Item 1 would leave `asl doctor` failing on all three binaries.

---

### Item 4: Master Verification (Full Gate & Consistency Audit)
- **Path**: Full monorepo verification harness
- **Identity**:
  - `:id`: `"item-4"` / `"Phase9MasterVerification"`
  - `:title`: `"Master Verification: all 7 gates and 5 consistency dimensions passed cleanly with capabilities lock in place"`
  - `:kind`: `:verification`
  - `:lane`: `"verification"`
- **Why**:
  - Validates that all Phase 9 implementations (`asl doctor`, `capabilities.lock`, instruction surface reconciliation, and engine binary parity) integrate cleanly without regressing any of the monorepo's 7 verification tiers (36 package manifests, 904 balanced ASL files, 12 grounded benchmark claims, pure monorepo boundary, 313 test suites with 8587 assertions, 3917 exported symbols, 22 modular skills) or 5 consistency dimensions (ADR bidirectional linkage, intent ledger coherence, D52 completeness, roadmap graph, delimiter/emoji invariants).
  - Verifies that `./bin/asl gate` and `./bin/asl audit consistency` pass cleanly with zero errors.
- **Context & Intent**:
  - `:context`: `D81PlanContext`, `D52`
  - `:purpose`: Comprehensive end-to-end verification of repository integrity under Phase 9 instruction truth and capability doctor updates.
  - `:outcomes`:
    - Composite verification pre-checks confirm Items 1-3 complete and locked.
    - `./bin/asl gate` passes all 7 verification tiers cleanly.
    - `./bin/asl audit consistency` passes all 5 epistemic dimensions with 0 defects.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D34", "D52", "D81"]`
  - `:variations`: None.
  - `:failure-modes`: Inadvertent foreign files created, syntax errors in `capabilities.lock`, broken ADR links.
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
  import subprocess, sys, os, hashlib

  # Gate 1 precheck: asl doctor & lock
  res = subprocess.run(["./bin/asl", "doctor"], capture_output=True, text=True)
  if res.returncode != 0 or ("capabilities" not in res.stdout.lower() and "measured" not in res.stdout.lower()):
      sys.exit("Item 1 incomplete: asl doctor failed or missing receipt")
  lock = "asl/grammar/capabilities.lock"
  if not os.path.exists(lock) or "(:capabilities-lock" not in open(lock).read():
      sys.exit("Item 1 incomplete: capabilities.lock missing or invalid")

  # Gate 2 precheck: instruction truth
  for f in ["AGENTS.md", "README.md"]:
      c = open(f).read()
      if "asl doc " in c or "asl task spawn" in c:
          sys.exit(f"Item 2 incomplete: absent command cited in {f}")

  # Gate 3 precheck: binary parity
  h1 = hashlib.sha256(open("bin/asl", "rb").read()).hexdigest()
  h2 = hashlib.sha256(open("asl/bin/asl", "rb").read()).hexdigest()
  h3 = hashlib.sha256(open("asl/asl", "rb").read()).hexdigest()
  if not (h1 == h2 == h3):
      sys.exit(f"Item 3 incomplete: binary divergence bin/asl={h1[:8]}, asl/bin/asl={h2[:8]}, asl/asl={h3[:8]}")

  print("Phase 9 prechecks passed")
  ' && ./bin/asl gate && ./bin/asl audit consistency
  ```
- **Current Baseline Failure**:
  ```text
  Item 1 incomplete: asl doctor failed or missing receipt
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-1", "item-2", "item-3"]`
- **File ownership (`owns`)**: `[]`
- **What breaks if run before prerequisite**: Fails immediately because Items 1, 2, and 3 have not been applied on the baseline tree.

---

## Risks
1. **Compilation Environment & Linking**:
   Recompiling `bin/asl` from `asl/tools/asl.c` requires linking against macOS JavaScriptCore (`clang -O2 -framework JavaScriptCore -o bin/asl asl/tools/asl.c`). Missing framework flags will lead to link-time errors.
2. **Lock File ASN Compliance (Invariants C1 & C2)**:
   The generated `asl/grammar/capabilities.lock` must strictly adhere to the machine ASN format: zero comments (`c-0001`), zero emojis (`c-0002`), balanced parentheses, and correct S-expression atoms. Inadvertent inclusion of comments or emojis will fail `./bin/asl check` and Gate 6 during `./bin/asl gate`.
3. **Execution Latency of Capability Probes**:
   If `asl doctor` executes full sub-processes for every capability, execution time could increase. Internal functional dispatches or lightweight assertions must be used where appropriate to keep doctor execution under 200ms.

---

## Out of Scope
1. **Benchmarking & Token Economy Research**:
   Benchmarking models, token consumption measurements, and LLM telemetry experiments are strictly excluded per scope directive.
2. **Compiler Self-Hosting Rewrites**:
   Migrating the C bootstrap runtime `asl/tools/asl.c` into pure self-hosted AgentScript is tracked under Phase 438/440 compiler self-hosting roadmaps.
3. **RPC Grep Fallthrough Elimination & Grammar Dispatch Reconciliation (Task46402)**:
   Refactoring the `:grep` / `:q` RPC dispatcher to eliminate silent fallthrough is tracked under Task46402. Phase 9 focuses strictly on Task46403 (`asl doctor`), Task46401 (instruction surface truth), binary reconciliation, and gate integrity.
4. **Acceptance Test Fixture Expansion (Task46405, Task46406)**:
   Writing acceptance fixtures across all 139 roadmap tasks in `tests/acceptance/` is tracked under Wave 105.

---

## Opportunities & Suggestions
1. **Integration into Verification Gate Tier 7**:
   Wire `capabilities.lock` freshness checking directly into Gate 7 or a dedicated Tier in `./bin/asl gate` to ensure hand edits to `asl/grammar/capabilities.asn` cannot diverge from measured capability realities.
2. **Machine-Readable Doctor Flag**:
   Support `./bin/asl doctor --format json` or `./bin/asl doctor --ndasn` for automated ingestion into external AI agent tools and monitoring dashboards.
3. **Automated Binary Sync Git Hook**:
   Implement a lightweight post-commit or pre-push verification hook checking byte equality across `bin/asl`, `asl/bin/asl`, and `asl/asl` to preemptively prevent binary distribution drift.
