# Phase 468 Plan Review: Intent, Goal and Practice Lifecycle (ADR-0081)

## Executive Summary
- **Target Plan**: `.plans/phase-468/PLAN.md`
- **Specification Source**: `.asl/mem/tasks/Phase468IntentGoalPracticeLifecycle.asn` (Task46801 through Task46805)
- **Reviewer Invocation**: Clean-context independent review under ADR-0081 / `steps-review`
- **Verdict**: **APPROVE-WITH-AMENDMENTS**
- **Blocker Count**: 3 amendments (contract alignment with grader fixtures)
- **Unverified Count**: 0 (all baseline probes, files, commands, and hashes independently verified)

---

## Verdict: APPROVE-WITH-AMENDMENTS

The plan is exceptionally thorough, topologically sound, grounded in measured repository metrics (469,582 tokens, 164 records with 1 superseded), and strictly enforces grader/implementer separation of duties. However, 3 amendments must be adopted in `PLAN.md` before implementation begins to avoid failing grader-owned acceptance test assertions on exact string contracts.

---

## Blockers & Required Amendments

### 1. Work Item 2 (Task46802): Principle Naming Mismatch in `.asl/mem/principles.asn`
- **Contract Evidence**: In `tests/acceptance/d81/Task46802.asl:28-30`:
  ```lisp
  (assert (or (string-contains? src "Reconstructibility")
              (string-contains? src "WriteThreshold"))
          "principles.asn must declare reconstructibility principle")
  ```
- **Plan Defect**: `PLAN.md:130` specifies adding principle `WriteOnlyWhatCannotBeReconstructed`.
- **Finding**: `"WriteOnlyWhatCannotBeReconstructed"` contains neither `"Reconstructibility"` (ends in `-ed`, not `-ibility`) nor `"WriteThreshold"`. Following the plan literally will cause `Task46802.asl` to fail.
- **Required Amendment**: Update Item 2 action steps to name the principle `PrincipleReconstructibility` or `ReconstructibilityThreshold`, ensuring `"Reconstructibility"` or `"WriteThreshold"` is present verbatim.

### 2. Work Item 2 (Task46802): Rule Wording Missing `"refused"` in `asl/grammar/rules.asn`
- **Contract Evidence**: In `tests/acceptance/d81/Task46802.asl:40-44`:
  ```lisp
  (assert (string-contains? src "refused")
          "rules.asn must specify refusal for reconstructible records")
  (assert (string-contains? src "names the command")
          "rules.asn must require refusal to name reporting command")
  ```
- **Plan Defect**: `PLAN.md:128` specifies:
  `Declare test: anything reconstructible from code, git history, or a command is not written down; refusal names the command...`
- **Finding**: The string `"refusal names the command"` contains `"refusal"`, but does NOT contain `"refused"`. Substring matching `string-contains?` will fail unless the word `"refused"` is present.
- **Required Amendment**: Update Item 2 action steps to mandate phrasing such as: `reconstructible records are refused and the refusal names the command`.

### 3. Work Item 4 (Task46804): Missing Helper Function Name for Dynamic Phase Counting in `asl/tools/asl.c`
- **Contract Evidence**: In `tests/acceptance/d81/Task46804.asl:17-19`:
  ```lisp
  (assert (or (string-contains? src "count_roadmap_phases")
              (string-contains? src "compute_phase_count"))
          "asl.c must dynamically compute phase count from roadmap")
  ```
- **Plan Defect**: `PLAN.md:244` specifies replacing `int phase_count = 39;` with dynamic counting by parsing `rcontent`, but does not prescribe the helper function identifier.
- **Finding**: If an implementer writes an inline loop or names the helper `count_phases` or `parse_roadmap_phases`, `Task46804.asl` assertion fails.
- **Required Amendment**: Update Item 4 action steps to explicitly instruct implementing a helper named either `count_roadmap_phases` or `compute_phase_count`.

---

## Non-Blocking Findings & Proactive Recommendations

1. **Explicit Token in `mem/src/amnesia.asl` (Item 3 / Task46803)**:
   - In `tests/acceptance/d81/Task46803.asl:36`, `(assert (string-contains? src "closure-condition"))` is evaluated.
   - `PLAN.md:188-190` lists `transition-to-retired`, `retire-chunk`, etc., but should note that `closure-condition` must appear verbatim in `amnesia.asl`.

2. **Explicit C Dispatch and Path Tokens (Item 5 / Task46805)**:
   - In `tests/acceptance/d81/Task46805.asl:18-20, 53-56, 63-66`, assertions expect `strcmp(argv[1], "mem") == 0`, `asl mem query` / `query_mem_records`, and references to `.asl/mem/intent.asn` or `.asl/mem/practices.asn`.
   - `PLAN.md:311-315` covers these concepts; implementer should ensure standard dispatch patterns are followed.

3. **Pre-Existing Baseline Binary Parity Discrepancy**:
   - `bin/asl` (`SHA256: 4f208c1d8153eca5630712a5292719d9b25ea8a6999f85ab58aac617f999bd77`, size 358,480 bytes) differs from `asl/bin/asl` and `asl/asl` (`SHA256: bb8ef8525eee1377341611696c82b8d81b09544cd8611595b0d6d1754e8ee19e`, size 324,624 bytes).
   - Although Items 4 and 5 prescribe copying `bin/asl` to `asl/bin/asl` and `asl/asl`, the implementer should synchronize binaries before beginning or immediately upon compiling to prevent divergent CLI execution.

4. **Upstream Task Dependency Audit**:
   - In `.asl/mem/tasks/Phase468IntentGoalPracticeLifecycle.asn`, tasks declare dependencies on completed phases:
     - Task46802: `["Task46801" "Task46504"]`
     - Task46803: `["Task46801" "Task46503"]`
     - Task46804: `["Task45504" "Task46801"]`
     - Task46805: `["Task46501" "Task46801"]`
   - All upstream tasks (Phase 455 and Phase 465) are confirmed `:state :done` in their respective task collections. `PLAN.md` lists intra-phase dependencies (`Task46801`, `Task46804`), which correctly reflects execution ordering for Phase 468.

5. **Line Range Citation Boundary Precision**:
   - The line ranges cited in `PLAN.md` (e.g. `mem/src/records.asl:1-249`, `asl/grammar/rules.asn:1-98`, `.asl/mem/intent.asn:1-888`) correspond exactly to 1-indexed view lines including trailing newlines.
   - Minor citation notes: `TOKEN_CONVENTIONS.md` cited `1-168` (actual 183 lines); `roadmap.asn` cited `1-170` (actual 182 lines).

---

## The Two Core Review Questions

### 1. What would a conformant-but-wrong implementation still pass?
- **Static Token Matching vs. Dynamic Execution in Grader Fixtures**:
  - Grader acceptance tests `Task46801.asl` through `Task46805.asl` primarily perform AST string verification (`file-read` and `string-contains?`).
  - A conformant-but-wrong implementation that defines stubbed or non-functional methods in `records.asl` or `amnesia.asl` might pass the immediate unit asserts in `Task4680X.asl`.
  - **Mitigation Present in Gate**: `SuperviseGate.sh` executes 3 tiers: (1) `Task4680X.asl`, (2) `bin/asl audit gates` (running all 319 native test suites and 8,741 assertions, checking delimiter balance, syntax balance, package manifests, and C host boundaries), and (3) `bin/asl audit consistency` (enforcing bidirectional ADR/task links, D52 schema completeness, and roadmap phase integrity).
  - Any syntax corruption, broken existing tests, or unparseable ASN will fail steps 2 or 3 of `SuperviseGate.sh`.

### 2. Does this gate check more or less?
- The gate checks **more** than task-local unit tests: it checks full monorepo integrity through the 7-tier verification audit and 5-dimension consistency audit on every task execution.
- No existing gate assertions are weakened or removed.

---

## Separation of Duties & Invariants Audit

| Check | Requirement | Status | Evidence |
|:---|:---|:---:|:---|
| **Separation of Duties** | Grader tests outside `:owns` | **PASS** | `tests/acceptance/d81/Task4680*.asl` and `SuperviseGate.sh` are strictly in `:verificationOwns`, zero in `:owns`. |
| **Invariant C1** | Zero comments in ASL | **PASS** | Audited 945 ASL files via `bin/asl audit gates` Gate 2. |
| **Invariant C2** | Zero emojis in ASN | **PASS** | Audited 183 ASN files via `bin/asl audit gates` Gate 6 and `bin/asl audit consistency`. |
| **Rules SSOT** | Deterministic render from `rules.asn` | **PASS** | `bash scripts/install.sh --check-rules` verified all 7 surfaces in lockstep. |
| **Falsifiable Baseline** | Exit code 1 on baseline probes | **PASS** | All 5 supervisor gates failed with code 1 for the intended semantic reason. |
| **Binary Parity** | `bin/asl == asl/bin/asl == asl/asl` | **AMENDMENT** | Discrepancy noted on baseline; plan includes synchronization during compilation. |

---

## Baseline Reproduction Log

```text
Task46801:
  Command: sh tests/acceptance/d81/SuperviseGate.sh Task46801
  Exit: 1
  Output: [ASL_ASSERTION_FAILURE]: records.asl must declare intent kind

Task46802:
  Command: sh tests/acceptance/d81/SuperviseGate.sh Task46802
  Exit: 1
  Output: [ASL_ASSERTION_FAILURE]: rules.asn must define write threshold rule

Task46803:
  Command: sh tests/acceptance/d81/SuperviseGate.sh Task46803
  Exit: 1
  Output: [ASL_ASSERTION_FAILURE]: amnesia.asl must define retire-chunk

Task46804:
  Command: sh tests/acceptance/d81/SuperviseGate.sh Task46804
  Exit: 1
  Output: [ASL_ASSERTION_FAILURE]: asl.c must not hardcode phase_count to literal 39

Task46805:
  Command: sh tests/acceptance/d81/SuperviseGate.sh Task46805
  Exit: 1
  Output: [ASL_ASSERTION_FAILURE]: asl.c must implement run_cmd_mem
```

---

## Unverified Items
None. Every cited path, line range, baseline failure output, binary checksum, and git rule check was directly executed and verified.
