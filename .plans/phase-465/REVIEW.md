# Phase 465 Plan Review: Agent Working Memory Surface (Revision 2)

## Verdict
**APPROVE-WITH-AMENDMENTS** (Plan resolves all 3 critical blockers from Revision 1; 4 actionable amendments specified for gate tightening and binary write parity).

- **Reviewer**: `steps-plan-reviewer` (Independent Clean-Context Audit)
- **Date**: 2026-09-12
- **Target Plan**: [.plans/phase-465/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-465/PLAN.md)
- **Canonical Specification**: [.asl/mem/tasks/Phase465AgentWorkingMemorySurface.asn](file:///Users/purplelephant/projects/asex/.asl/mem/tasks/Phase465AgentWorkingMemorySurface.asn)
- **Governing ADR**: [Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn](file:///Users/purplelephant/projects/asex/.asl/mem/decisions/Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn)

---

## Audit of Prior Blockers

### Blocker 1: Work Item Gates Test Physical Semantics Rather Than Missing Acceptance Fixtures
- **Status**: **RESOLVED** (Decoupled from acceptance suite; per-item gates test physical semantics, with amendments needed for Item 5 and Item 6).
- **Physical Verification**:
  - In Revision 1, all 6 items invoked composite `sh tests/acceptance/d81/SuperviseGate.sh Task4650X` which exited 3 due to missing verifier fixtures and ran monorepo-wide audits.
  - In [.plans/phase-465/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-465/PLAN.md), the planner decoupled work item gates from verifier acceptance fixtures:
    - Item 1: `./bin/asl test --strict-falsify mem/tests/tasks_test.asl mem/tests/checkpoint_test.asl` (verified 193 passing assertions across facade and checkpoint).
    - Item 2: `./bin/asl note list && ./bin/asl rpc '(:batch (:note :list))'` (verified baseline failure: `Error: unrecognized subcommand 'note'` exit 1, batch RPC rejected with `:ERR_UNIMPLEMENTED`).
    - Item 3: `./bin/asl test --strict-falsify mem/tests/worklist_test.asl` (verified baseline failure: test file not found exit 1; author-owned unit test).
    - Item 4: `./bin/asl test --strict-falsify mem/tests/notes_scope_test.asl` (verified baseline failure: test file not found exit 1; author-owned unit test).
    - Item 5: `bash scripts/install.sh --check-rules` (runs in 1s; see Amendment 1 below).
    - Item 6: `test -f .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && ./bin/asl check ...` (verified baseline failure: exit 1; see Amendment 3 below).
  - Independent acceptance fixtures `tests/acceptance/d81/Task46501.asl` through `Task46506.asl` are now held on disk and evaluated separately by `independentVerifier` via `SuperviseGate.sh`. When executed, fixtures fail with exact assertion contracts (e.g. `[ASL_ASSERTION_FAILURE]: asl.c must implement run_cmd_note`).

---

### Blocker 2: Mechanical Separation Violation
- **Status**: **RESOLVED**.
- **Physical Verification**:
  - In Revision 1, `tests/acceptance/d81/Task4650X.asl` was listed under `:owns` and assigned to the implementer in its Action-DAG.
  - In [.plans/phase-465/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-465/PLAN.md), all acceptance fixtures have been completely removed from implementer `:owns` and `:action-dag` across all six items.
  - Acceptance fixtures are assigned strictly to `independentVerifier` under `verificationOwns` and evaluated in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task4650X`.
  - Implementer ownership is confined strictly to production code and author-owned development unit tests (`mem/tests/worklist_test.asl`, `mem/tests/notes_scope_test.asl`), fully conforming to ADR-0081 Driver 8 and rule `hiddenTests` ([asl/grammar/rules.asn:43-45](file:///Users/purplelephant/projects/asex/asl/grammar/rules.asn#L43-L45)).

---

### Blocker 3: Complete `:owns` Sets for Binaries, Manifest, and Rendered Skills
- **Status**: **RESOLVED** (with minor alignment on Item 3).
- **Physical Verification**:
  - Item 2 `:owns` now explicitly declares `["bin/asl", "asl/bin/asl", "asl/asl"]` (line 164), ensuring compiled binaries have transactional write authority.
  - Item 3 `:owns` now includes package manifest `"mem/manifest.asn"` (line 225) and persistent store `".asl/mem/worklist.asn"`.
  - Item 5 `:owns` now declares all seven rendered surfaces: `["asl/grammar/rules.asn", "scripts/install.sh", "AGENTS.md", ".agents/skills/asl-toolbelt/SKILL.md", "asl/.agents/skills/asl-toolbelt/SKILL.md", ".agents/skills/asl-toolbelt/skill.asn", "asl/.agents/skills/asl-toolbelt/skill.asn"]` (line 339), matching `scripts/install.sh:62-89`.

---

## Amendments (Requirements for Implementation)

### Amendment 1: Tighten Item 5 Gate from Vacuous Baseline Pass
- **Issue**:
  - Item 5 specifies gate `bash scripts/install.sh --check-rules`.
  - On the current clean tree, `bash scripts/install.sh --check-rules` outputs `rules: all surfaces identical...` and exits 0.
  - A conformant-but-wrong implementation that leaves `asl/grammar/rules.asn` untouched would pass this gate immediately, violating rule `gates` ([asl/grammar/rules.asn:17-19](file:///Users/purplelephant/projects/asex/asl/grammar/rules.asn#L17-L19)).
- **Remediation**:
  - Replace Item 5 gate with:
    ```bash
    grep -q '(:rule :id note' asl/grammar/rules.asn && ! grep -q 'until the ledger ops exist' asl/grammar/rules.asn && bash scripts/install.sh --check-rules
    ```
  - Direct reproduction confirms this fails on baseline (exit code 1) and will pass only when the `:id note` rule is written, the concession retired, and all 7 client surfaces rendered without drift.

### Amendment 2: Align Item 3 `:owns` with Engine Binary Recompilation
- **Issue**:
  - Item 3 lists `asl/tools/asl.c` in `:owns` (line 225) and `:additional-requirements` specifies recompiling engine binaries if `asl.c` is updated (line 205).
  - However, `["bin/asl", "asl/bin/asl", "asl/asl"]` are omitted from Item 3 `:owns`.
- **Remediation**:
  - If Item 3 modifies `asl/tools/asl.c` to bind worklist RPC operations, add `["bin/asl", "asl/bin/asl", "asl/asl"]` to Item 3 `:owns`. Alternatively, if worklist cursor operations route through the generic batch RPC dispatch added in Item 2 without C engine modifications, remove `asl/tools/asl.c` from Item 3 `:owns`.

### Amendment 3: Tighten Item 6 Gate to Verify Comparative Evaluation Contents
- **Issue**:
  - Item 6 specifies gate `test -f .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && ./bin/asl check .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn`.
  - An empty or stub file `(:telemetry)` passes `./bin/asl check` without performing the comparative benchmark.
- **Remediation**:
  - Align Item 6 gate with the acceptance contract in `tests/acceptance/d81/Task46506.asl:12-15`:
    ```bash
    test -f .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && grep -q ':memoryWithheld' .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && grep -q ':unsupportedClaims' .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && ./bin/asl check .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn
    ```

### Amendment 4: Clarify Item 1 Invariant Baseline Role
- **Issue**:
  - Item 1 gate `./bin/asl test --strict-falsify mem/tests/tasks_test.asl mem/tests/checkpoint_test.asl` reports 193 passing assertions on baseline (exit code 0), and verifier fixture `Task46505.asl` passes with 21 assertions.
- **Remediation**:
  - The implementer should treat Item 1 as an invariant verification baseline step: verify non-zero execution under `--strict-falsify`, execute zero production code mutations if suites already pass, and proceed to Item 2.

---

## Non-blocking (Suggestions & Refinements)

1. **Previous Revision Non-blocking Confirmations**:
   - Checkpoint source range citation in Item 1 updated to `mem/src/checkpoint.asl:1-178` (confirmed updated).
   - Target symbol alignment for session recovery in Item 2 aligned to `task-recover-session` (confirmed updated).
   - Worklist persistent storage path declared as `.asl/mem/worklist.asn` in Item 3 (confirmed updated).
2. **Proactive Suggestion — Worklist Seeding Helper**:
   Provide a helper RPC or subcommand `asl worklist seed --git-diff` that parses staged or modified paths into a ready-to-walk worklist for implementers.

---

## Unverified

1. **Benchmark Model Sensitivity in Item 6**:
   Whether the comparative benchmark task set in `asl/bench` can be evaluated deterministically in local headless execution without external API dependencies remains unverified until Item 6 harness scripts are authored. Implementers should ensure the benchmark relies on deterministic AST token verification and step counts rather than network-bound LLM endpoints.
