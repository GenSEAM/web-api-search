# Phase 439 Plan: Efficiency Final Review

## Status
- **Phase**: Phase439EfficiencyFinalReview
- **Priority**: Epistemic Measurement & Quantitative Claim Validation
- **Status**: completed

## Context & Objectives
Execute Phase 439 under ADR-0081 and monorepo verification contracts:

1. **Task43901**: Measure real fault detection separately from assertion falsification
   - *Rationale*: Fault sensitivity matters more than printed counts, but assertion inversion is not implementation mutation testing.
2. **Task43902**: Measure actual cache use and cost per correct task
   - *Rationale*: Byte stability is useful but does not prove cache hits, provider eligibility or end-to-end savings.
3. **Task43903**: Independently reproduce every current quantitative claim
   - *Rationale*: Historical receipts and existing source paths do not establish current reproducibility.
4. **Task43904**: Validate the complete task graph and truthful completion states
   - *Rationale*: Whole-ledger consistency requires graph and provenance checks, not a task-count banner or deletion of an aggregate filename.

## Work Breakdown & Ordered DAG

### Step 1: Task43901 — Measure real fault detection separately from assertion falsification
- **Fixture**: `tests/acceptance/d81/Task43901.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43901`
- **Owned Files**: `asl/tools/asl.c`, `AGENTS.md`, `asl/grammar/verification-contract.asn`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Rationale*: Fault sensitivity matters more than printed counts.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43901`.
  2. Implement mutation-based fault detection verification in C host and rules.
  3. Execute gate and verify assertions execute cleanly.

### Step 2: Task43902 — Measure actual cache use and cost per correct task
- **Fixture**: `tests/acceptance/d81/Task43902.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43902`
- **Owned Files**: `asl/bench/launch_stability.asl`, `asl/tools/asl.c`
- **Rationale**: Byte stability is useful but does not prove cache hits.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43902`.
  2. Implement telemetry to record real prompt cache hit ratios and task costs.
  3. Execute gate and verify assertions pass.

### Step 3: Task43903 — Independently reproduce every current quantitative claim
- **Fixture**: `tests/acceptance/d81/Task43903.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43903`
- **Owned Files**: `asl/bench`, `asl/bench/published_claims.asn`, `.asl/mem/receipts.asn`
- **Rationale**: Historical receipts do not establish current reproducibility.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43903`.
  2. Audit claims against live re-evaluations and record signed receipts.
  3. Execute gate and verify assertions pass.

### Step 4: Task43904 — Validate the complete task graph and truthful completion states
- **Fixture**: `tests/acceptance/d81/Task43904.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43904`
- **Owned Files**: `asl/tools/asl.c`, `.asl/mem/tasks`, `.asl/mem/decisions`, `.asl/mem/roadmap.asn`, `mem/grammar.asn`, `.asl/mem/reviews/D81PlanSettlement.asn`, `.asl/mem/intent.asn`, `.asl/mem/decisions.asn`
- **Rationale**: Whole-ledger consistency requires graph and provenance checks.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43904`.
  2. Harmonize task DAG dependencies, clean up phantom owns paths, verify completion states.
  3. Execute gate and verify assertions pass.
