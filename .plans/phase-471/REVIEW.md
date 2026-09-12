# Phase 471 Plan Review: Closing the Unplanned

## Verdict
**APPROVE-WITH-AMENDMENTS**

The plan at [.plans/phase-471/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-471/PLAN.md) is structurally sound, strictly adheres to mechanical separation of duties, includes complete ownership sets with binary parity targets, and establishes falsifiable baseline failures across all work items. Three actionable amendments are required to ensure complete contract conformance with Task47101-Task47103 and prevent conformant-but-incomplete implementations from passing intermediate gates.

- **Reviewer**: `steps-plan-reviewer` (Independent Clean-Context Audit)
- **Date**: 2026-09-12
- **Target Plan**: [.plans/phase-471/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-471/PLAN.md)
- **Canonical Specification**: [.asl/mem/tasks/Phase471ClosingTheUnplanned.asn](file:///Users/purplelephant/projects/asex/.asl/mem/tasks/Phase471ClosingTheUnplanned.asn)
- **Governing ADR**: [Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn](file:///Users/purplelephant/projects/asex/.asl/mem/decisions/Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn)

---

## Evaluation of Core Protocol Verification Dimensions

### 1. Conformance to ADR-0081 and Tasks Task47101–Task47103
- **Task47101 (Repository Plan Verification)**: Conforms in intent by porting ephemeral session verification scripts into native CLI subcommand `asl audit plan`. Accurately cites and preserves D52 validation logic (`asl/tools/asl.c:3407`).
  - *Finding*: The plan omitted explicit mention of unordered writer pair computation (the historical 529 and 1309 figures cited in `.asl/mem/tasks/Phase458LedgerTruthAndWriteDiscipline.asn:8` and `Phase471ClosingTheUnplanned.asn:8,15,16,18,28`) from Item 1 outcomes and action-dag. See **Amendment 1**.
- **Task47102 (Authoring Scaffolding & Staging)**: Conforms to ADR-0081 by designing native templates for modules, functions, and non-stub test suites, while activating batch RPC staged editing (`:diff`, `:flush`, `:discard`) and flipping `probe_stagedEdit` from `CAP_STATUS_LIES` to `CAP_STATUS_WORKS`.
  - *Finding*: Item 2 gate only exercises `asl scaffold`, leaving staged editing unverified by the developer gate. See **Amendment 2**.
- **Task47103 (Dependency Ledger Truth)**: Conforms to ADR-0081 Driver 9 and dependency classifications by purging the obsolete `python3` entry at `.asl/mem/dependencies.asn:28-41` and distinguishing build boundaries from runtime substrate requirements.

### 2. Baseline Gate Falsifiability & Physical Reproduction
All three gate commands were reproduced directly on the baseline repository tree:
- **Item 1 Gate (`./bin/asl audit plan`)**:
  - *Baseline Output*: `Usage: asl audit <consistency|gates|bind|dup|dead|doctor>`
  - *Exit Code*: `1` (Fails as expected; subcommand unrecognized).
- **Item 2 Gate (`./bin/asl scaffold module sample_mod --dry-run && ./bin/asl scaffold test sample_test --dry-run`)**:
  - *Baseline Output*: `Error: unrecognized subcommand 'scaffold'`
  - *Exit Code*: `1` (Fails as expected; subcommand unrecognized).
- **Item 3 Gate (`! grep -q 'name "python3"' .asl/mem/dependencies.asn && ./bin/asl check .asl/mem/dependencies.asn`)**:
  - *Baseline Output*: (no stdout/stderr)
  - *Exit Code*: `1` (Fails as expected; grep matches active `name "python3"` entry at `.asl/mem/dependencies.asn:29`).

### 3. Separation of Duties (Invariant `hiddenTests` & ADR-0081 Driver 8)
- **Implementer Boundary**: Implementer `:owns` strictly encompasses production code and specifications: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `mem/src/structural_editor.asl`, `.asl/mem/dependencies.asn`, `asl/grammar/dependency-boundaries.asn`, and compiled binaries.
- **Grader Boundary**: Grader-owned acceptance test fixtures (`tests/acceptance/d81/Task47101.asl`, `Task47102.asl`, `Task47103.asl`) and acceptance test runner (`tests/acceptance/d81/SuperviseGate.sh`) are isolated exclusively under `verificationOwns` and evaluated solely by `independentVerifier`.
- The plan correctly corrected an anomaly in `.asl/mem/tasks/Phase471ClosingTheUnplanned.asn:19` (which had mistakenly included `"tests/acceptance/d81"` in implementer `:owns`).

### 4. Complete `:owns` Sets and Binary Parity Targets
- The binary targets `["bin/asl", "asl/bin/asl", "asl/asl"]` are explicitly included in `:owns` for both Item 1 (line 83) and Item 2 (line 145).
- Binary parity across all three targets was verified on the clean baseline tree (identical SHA-256: `062b0d643e83cc7caf2a015cb3cf81573cec128ca49fac9be4b8da7015536713`).
- Item 3 strictly touches data/spec files and appropriately does not include binary rebuild targets.

### 5. Invariants C1 (Zero Comments), C2 (Zero Emojis), and ADR-0081
- **File Content Audit**: [.plans/phase-471/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-471/PLAN.md) contains zero emojis (100% ASCII verified) and zero extraneous comments.
- **ADR-0081 Invariant Disposition**: ADR-0081 retired unconditional Invariant C1 for C and generated projections ("concise useful rationale permitted by settled source policy"), while preserving C1 for pure ASL modules (`mem/src/structural_editor.asl`) and Invariant C2 (zero emojis in machine ASN files). The plan complies with these invariants.

---

## Blockers
*None* (Zero blocking architectural flaws; all critical findings are resolved via the three actionable amendments below).

---

## Mandatory Amendments (Action Items for Implementation)

### Amendment 1: Incorporate Unordered Writer Pair Detection in Item 1 (`Task47101`)
- **Evidence**:
  - In [.asl/mem/tasks/Phase471ClosingTheUnplanned.asn:16,28](file:///Users/purplelephant/projects/asex/.asl/mem/tasks/Phase471ClosingTheUnplanned.asn#L16-L28), Task47101 explicitly requires:
    - `:purpose`: *"reports cycles, missing fields, unregistered tasks, dangling dependencies and unordered writer pairs, and fails on any."*
    - `:verificationCases`: *"The unordered writer pair count it reports matches an independent computation on the same tree."*
  - In `PLAN.md:41-46,51-56,67-71`, Item 1 lists DAG cycle detection, D52 field completeness, dangling dependencies, and unregistered tasks, but omits unordered writer pair computation.
- **Remediation**:
  - Implementer must ensure `asl audit plan` detects and reports pairs of tasks that write to the same file (`:owns`) without a dependency path (`:dependsOn`) ordering them.
  - Report the detected unordered writer pair count alongside cycle and D52 checks so that acceptance test verification case 4 passes.

### Amendment 2: Tighten Item 2 Gate to Verify Staged RPC Operations (`Task47102`)
- **Evidence**:
  - Item 2 scope covers two distinct halves: native scaffolding (`asl scaffold`) and staged batch RPC operations (`:diff`, `:flush`, `:discard`).
  - Item 2 gate currently only tests scaffolding: `./bin/asl scaffold module sample_mod --dry-run && ./bin/asl scaffold test sample_test --dry-run`.
  - A conformant-but-incomplete implementation that only implements scaffolding and leaves RPC staging in its baseline unsupported state would pass this gate immediately.
- **Remediation**:
  - Implementer must augment Item 2 development gate to also verify that staged RPC operations are recognized and not rejected with `:ERR_UNSUPPORTED`:
    ```bash
    ./bin/asl scaffold module sample_mod --dry-run && ./bin/asl scaffold test sample_test --dry-run && ! ./bin/asl rpc '(:batch (:diff))' | grep -q ':ERR_UNSUPPORTED'
    ```
  - This fails on baseline (exit code 1) and will pass once staging is wired.

### Amendment 3: Explicit Grounding of Build Boundary Classification in Item 3 (`Task47103`)
- **Evidence**:
  - Task47103 requires: *"Build boundaries distinguished from runtime requirements"*.
  - Item 3 gate currently checks `! grep -q 'name "python3"' .asl/mem/dependencies.asn && ./bin/asl check .asl/mem/dependencies.asn`.
  - Simply deleting `python3` from `.asl/mem/dependencies.asn` passes this gate without establishing the explicit linkage or classification of build boundaries (`clang`, `gcc`, `JavaScriptCore`) declared in `asl/grammar/dependency-boundaries.asn:6-18`.
- **Remediation**:
  - Ensure `.asl/mem/dependencies.asn` explicitly classifies or cross-references the bootstrap and test boundary tiers from `asl/grammar/dependency-boundaries.asn` so the dependency ledger truthfully reflects non-runtime constraints.

---

## Non-blocking (Suggestions & Proactive Refinements)

1. **Pre-Commit Hook for Plan Audit**:
   Integrate `asl audit plan` into the repository pre-commit checks to catch DAG cycles and D52 metadata errors prior to commit.
2. **Graphviz DOT Representation**:
   Support an optional `--dot` flag in `asl audit plan` to visualize phase dependencies and writer overlaps.
3. **Interactive Scaffolding**:
   Consider adding an `--interactive` mode to `asl scaffold` in a future phase to prompt for module docstrings and exports.

---

## Unverified

1. **Circular Dependency Recursion Depth**:
   Cycle detection traversal across all `.asl/mem/tasks/*.asn` files should maintain an explicit visited/recursion set in memory to prevent stack exhaustion on deeply nested or densely interconnected graphs. This property will be verified during verifier acceptance execution.
