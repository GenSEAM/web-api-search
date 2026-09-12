# Phase 444 Plan: Test Telemetry and Coverage Guarantees

## Status
- **Phase**: Phase444TestTelemetryAndCoverageGuarantees
- **Priority**: High (Wave 96)
- **Status**: completed

## Context & Objectives
Execute and certify Phase 444 under ADR-0081 and monorepo verification contracts, establishing per-assertion telemetry, three decidable coverage guarantees, evaluator deficit closure, budgeted mutation testing with equivalence triage and digest caching, flakiness and bottleneck detection, and LLM test proposal within a mutation-feedback loop:

1. **Task44401**: Test telemetry record
   - *Rationale*: Record per-assertion identity, individual execution timing, and attributed unbound-symbol deficits (`ERR_UNBOUND_SYMBOL`) in session telemetry.
   - *Implementation*: `asl/tools/engine.js`, `asl/tools/asl.c`, `.asl/mem/telemetry/TestExecution20260912.asn`
   - *Acceptance Gate*: `sh tests/acceptance/d81/SuperviseGate.sh Task44401` (34 assertions passed)
2. **Task44402**: Three decidable coverage guarantees, gated; mutation score as quality metric
   - *Rationale*: Enforce symbol coverage, executed-assertion parity, and case kinds requirements per area while tracking mutation score as a distinct quality metric.
   - *Catalog*: `docs/TEST_CASE_CATALOG.md`
   - *Acceptance Gate*: `sh tests/acceptance/d81/SuperviseGate.sh Task44402` (53 assertions passed)
3. **Task44403**: Close evaluator deficit: missing builtins and unresolved aliases
   - *Rationale*: Close evaluator gap by implementing missing builtins (`list-take`, `list-fold`, `foldl`, `option-none?`, `list-filter`, `evalNode`, etc.) and recursive alias resolution, raising executed assertions to 92.8%.
   - *Implementation*: `asl/tools/engine.js`, `asl/tools/asl.c`
   - *Acceptance Gate*: `sh tests/acceptance/d81/SuperviseGate.sh Task44403` (36 assertions passed)
4. **Task44404**: Mutation strategy under a budget: selection, equivalence and incrementality
   - *Rationale*: Implement deterministic selection rule with recorded seed, equivalent mutant triage with written justification, and incremental digest caching in `asl mutate`.
   - *Corpus & Module*: `asl/bench/tasks/mutation_corpus.asn`, `asl/bench/mutation_strategy.asl`, `asl/tools/asl.c`
   - *Acceptance Gate*: `sh tests/acceptance/d81/SuperviseGate.sh Task44404` (44 assertions passed)
5. **Task44405**: Flakiness, bottlenecks and regression detection from repeated runs
   - *Rationale*: Evaluate outcome stability across repeated runs, disqualify unstable suites from guarantees, detect executed-assertion regressions naming both receipts, and rank bottlenecks by wall-clock share.
   - *Implementation*: `asl/bench/flakiness_detector.asl`, `scripts/run-gate-tests.sh`
   - *Acceptance Gate*: `sh tests/acceptance/d81/SuperviseGate.sh Task44405` (36 assertions passed)
6. **Task44406**: LLM case proposal inside a mutation-feedback loop, never as the oracle
   - *Rationale*: Enforce loop where model proposes candidate cases for surviving mutants, keeping only those that kill mutants and pass non-vacuity checks, while ownership enforcement forbids editing existing assertions or grader acceptance paths.
   - *Implementation*: `asl/bench/mutation_proposer_loop.asl`
   - *Acceptance Gate*: `sh tests/acceptance/d81/SuperviseGate.sh Task44406` (36 assertions passed)

## Verification Receipt
- **Accepted Tasks**: Task44401, Task44402, Task44403, Task44404, Task44405, Task44406 (6/6 complete, 100%)
- **Total Acceptance Assertions Evaluated**: 239 assertions executed under SuperviseGate.sh
- **Continuous Audit**: All 7/7 pure ASL verification gates passed cleanly; all 5/5 D52 consistency dimensions reconciled
