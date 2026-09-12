# Phase 442 Plan: Agent Reliability & Observability Utilities

## Status
- **Phase**: Phase442AgentReliabilityUtilities
- **Priority**: Critical Developer Tooling & Verification Ground Truth
- **Status**: in-progress

## Context & Objectives
Close the agent blind spots measured empirically in session 43abe3b2:
1. An agent cannot verify its own tools -> `asl doctor` probes utilities and RPC ops.
2. An agent cannot run a shell command and read its real exit status safely -> `(:run cmd)` in batch RPC.
3. Concurrent writers overwrite code without detection -> `:claim`, `:leases`, `:ERR_STALE_FILE`.
4. Structural plan checks are manual -> `asl plan verify` / `asl audit plan`.
5. Prior decisions and tasks are unsearchable -> `(:q)` over resident BM25.
6. Delimiter imbalance blocks gates unnoticed -> `asl watch`.
7. Session operations are forgotten across steps -> `(:trace)` append-only log.
8. Test coverage per symbol is unmapped -> `asl coverage`.
9. Reflection is ungrounded -> `asl reflect`.
10. Declared capabilities drift from reality -> `asl doctor` writes `capabilities.lock` and Gate 7 gates drift.

## Work Breakdown & Ordered DAG

### Step 1: Task44201 — asl doctor Environment & Capability Truth Probe
- Fixture: `tests/acceptance/d81/Task44201.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44201`
- Baseline: `asl doctor` not implemented in `asl/tools/asl.c`.
- Implementation: Implement `run_doctor` in `asl/tools/asl.c`, registering subcommand `doctor` in `main()`, validating core utilities and RPC ops against known fixtures, emitting ASN capability map, exiting 0 on clean capabilities.

### Step 2: Task44202 — Structured Supervised Execution (:run cmd)
- Fixture: `tests/acceptance/d81/Task44202.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44202`
- Implementation: Add `:run` operator in RPC engine with timeout, real exit code, bounded stdout/stderr.

### Step 3: Task44203 — Concurrent Writer Leases & Staleness Detection
- Fixture: `tests/acceptance/d81/Task44203.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44203`
- Implementation: Implement `:claim` and `:leases` RPC ops, verifying path digests before mutation.

### Step 4: Task44204 — Executable Plan Verifier (asl plan verify)
- Fixture: `tests/acceptance/d81/Task44204.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44204`
- Implementation: Enhance plan audit to verify DAG acyclicity, task references, and baseline failure integrity.

### Step 5: Task44205 — Semantic Recall (:q) with BM25
- Fixture: `tests/acceptance/d81/Task44205.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44205`
- Implementation: Wire `:q` to BM25 search over `.asl/mem` and codebase.

### Step 6: Task44206 — Continuous Pre-Flight (asl watch)
- Fixture: `tests/acceptance/d81/Task44206.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44206`
- Implementation: Implement `asl watch` subcommand.

### Step 7: Task44207 — Append-Only Session Trace (:trace)
- Fixture: `tests/acceptance/d81/Task44207.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44207`
- Implementation: Record every mutating RPC op to `.asl/mem/trace.asn`.

### Step 8: Task44208 — Coverage & Case-Diversity Map (asl coverage)
- Fixture: `tests/acceptance/d81/Task44208.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44208`
- Implementation: Symbol-level test reference mapping.

### Step 9: Task44209 — Reflection Utility (asl reflect)
- Fixture: `tests/acceptance/d81/Task44209.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44209`
- Implementation: Grounded reflection against observed trace.

### Step 10: Task44210 — Measured Capability Registry (capabilities.lock)
- Fixture: `tests/acceptance/d81/Task44210.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task44210`
- Implementation: `asl doctor` generates `capabilities.lock` and Gate 7 validates drift.
