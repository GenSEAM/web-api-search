# Plan Review: Phase 8 (Verification Layer Honesty & Static Analysis Toolchain)

## Verdict
**APPROVE-WITH-AMENDMENTS**

The execution plan in `.plans/phase-8/PLAN.md` has been reviewed in a clean context against repository state, the steps protocol, and Tasks 45501, 45701, 45702, 45703, and 47303. The overall architecture, scope, topological DAG ordering, and file ownership boundaries are sound. Approval is granted with three mandatory amendments to prevent conformant-but-defective implementations and ensure strict gate falsifiability.

---

## Evaluation Against Steps Protocol Standards

### 1. Epistemic Grounding & Baseline Gate Verification
- **Item 1 (`Task45501` - CLI Test Argument Honesty)**:
  - *Baseline Verification*: Confirmed. `./bin/asl test` on the current tree exits with code 0 silently. The gate command fails on disk as expected with `Error: asl test with no args returned silent zero` (Exit code 1).
- **Item 2 (`Task45701-45703` - Static Analysis Subcommands: `bind`, `dup`, `dead`)**:
  - *Baseline Verification*: Confirmed. Running `./bin/asl audit bind` on the current tree fails with `Usage: asl audit <consistency|gates>` (Exit code 1).
- **Item 3 (`Task47303` - Binary Parity & Distribution Reconciliation)**:
  - *Baseline Verification*: The current gate (`h1 == h2 == h3`) passes on the baseline tree (Exit code 0) because `bin/asl`, `asl/bin/asl`, and `asl/asl` are currently identical. While divergence occurs once Items 1-2 recompile `bin/asl`, the gate lacks baseline falsifiability before implementation (addressed in Amendment 2).
- **Item 4 (Master Verification)**:
  - *Baseline Verification*: Confirmed. Item 4 composite pre-check fails at baseline with `Item 1 incomplete: asl test did not refuse empty invocation` (Exit code 1). Both `./bin/asl gate` (all 7 tiers, 313 test suites) and `./bin/asl audit consistency` (all 5 epistemic dimensions) pass cleanly on the current baseline tree.

### 2. File Ownership Boundaries (`owns`)
- `Item 1`: `["asl/tools/asl.c"]`
- `Item 2`: `["asl/tools/asl.c"]` (strictly serialized via `depends_on: ["item-1"]`)
- `Item 3`: `["bin/asl", "asl/bin/asl", "asl/asl"]` (strictly serialized via `depends_on: ["item-1", "item-2"]`)
- `Item 4`: `[]` (read-only verification, `depends_on: ["item-1", "item-2", "item-3"]`)
Sequential wave serialization eliminates parallel write hazards across all work items.

---

## Required Amendments (Blockers if unamended)

### Amendment 1 (Item 1): Enforce Non-Flag Target Requirement and Expand Gate
- **Evidence**:
  In `PLAN.md:8-13`, the suggested C check is:
  ```c
  if (argc >= 2 && strcmp(argv[1], "test") == 0) {
      if (argc < 3) {
          fprintf(stderr, "Usage: asl test [options] <files...>\n");
          return 1;
      }
  ```
  In `asl/tools/asl.c:4206-4245`, when options are passed (e.g. `./bin/asl test --strict-falsify`), `argc` is 3. The check `if (argc < 3)` evaluates to false. Inside the file iteration loop, lines 4214 continue past `--strict-falsify`, no test files are run, and `return fail` returns 0.
  Crucially, Task45501 (`Phase455VerificationLayerHonesty.asn:22`) was created specifically because `"Phase435 gate, which is written as asl test --strict-falsify with no path... cannot fail under any condition"`.
- **Requirement**:
  1. The CLI dispatch must count actual target files (arguments starting with neither `-` nor `--`). If target file count is 0, it must print usage to stderr and exit with code 1.
  2. The gate for Item 1 must test BOTH empty invocation (`./bin/asl test`) and flag-only invocation (`./bin/asl test --strict-falsify`), asserting that both exit non-zero with usage error. It must also verify that a valid test file (`./bin/asl test intel/tests/cli_test.asl`) passes cleanly with exit code 0.

### Amendment 2 (Item 3): Ensure Item 3 Gate Fails on Baseline
- **Evidence**:
  `PLAN.md:173-184` checks only `h1 == h2 == h3`. On the baseline tree before implementation, `bin/asl`, `asl/bin/asl`, and `asl/asl` are byte-identical, so the gate currently exits 0. A gate that passes at baseline fails the core steps protocol requirement that work item verification gates fail before implementation.
- **Requirement**:
  Item 3 gate must additionally assert that the replica binaries (`asl/bin/asl` and `asl/asl`) embody the updated Phase 8 behavior (e.g. refusing empty `./asl/bin/asl test`). On the baseline tree, this immediately fails (exit code 1) because baseline `./asl/bin/asl test` returns 0. It will only pass once Item 3 reconciles newly compiled binaries across all paths.

### Amendment 3 (Item 2): Substantive Audit Output Assertion
- **Evidence**:
  `PLAN.md:127` checks `if "✓" not in res.stdout and "audited" not in res.stdout.lower() and "passed" not in res.stdout.lower()`. A stub printing `"✓ passed"` and exiting 0 would conform but be semantically hollow.
- **Requirement**:
  Item 2 gate must assert that `asl audit bind`, `asl audit dup`, and `asl audit dead` emit substantive audit statistics (e.g. file or module counts, or non-empty audit receipts) in addition to checkmarks and exit code 0.

---

## Non-blocking Suggestions

1. **Gate Tier Integration (`Tier 8`)**:
   Once `asl audit bind`, `dup`, and `dead` are implemented and verified, consider integrating them into `./bin/asl gate` as an 8th tier in a subsequent phase.
2. **Build Script Alignment**:
   In Item 3, implementers can invoke `scripts/build_and_install.sh` or replicate its compilation and copy pipeline (`cp -f bin/asl asl/bin/asl && cp -f bin/asl asl/asl`) to guarantee atomic parity.

---

## Unverified
None. All cited lines (`asl/tools/asl.c:4158-4167`, `asl/tools/asl.c:4205-4262`), task contracts, and gate commands were independently verified against disk state.

