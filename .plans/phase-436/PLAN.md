# Phase 436 Plan: Language Semantics Ground Truth

## Status
- **Phase**: Phase436LanguageSemanticsGroundTruth
- **Priority**: Critical Language Semantics & Evaluator Ground Truth
- **Status**: completed

## Context & Objectives
Execute Phase 436 under ADR-0081 and monorepo verification contracts:

1. **Task43601**: Bind imports and define loud evaluator failures
   - *Rationale*: Import resolution and explicit failures are prerequisites for trustworthy tests and the bootstrap; prior audit diagnoses require independent baseline reproduction.
2. **Task43602**: Require Boolean test results and stable assertion identities
   - *Rationale*: Test discovery, return values and assertion identities need explicit semantics; broad naming patterns must not silently skip entry points.
3. **Task43603**: Make RPC capability and result contracts honest
   - *Rationale*: Machine-readable capabilities and explicit failures reduce false confirmation; speed and model benefits remain hypotheses.
4. **Task43604**: Document immediate editing and define the staging transition
   - *Rationale*: Editing must report state it actually holds; the transition must allow a correct no-op discard.
5. **Task43605**: Verify assertion reachability and preserve runner failures
   - *Rationale*: Reached sites, repeated executions and source declarations are different quantities; numeric coverage cannot be inferred from text labels.
6. **Task43606**: Ground claims in executable evidence and reject empty catalogs
   - *Rationale*: Published claims require provenance and a reproducible measurement, not self-comparison or file existence.
7. **Task43607**: Declare host boundaries and detect foreign package logic
   - *Rationale*: Pure application source and independence from required third-party binaries are distinct boundaries; audit both honestly.

## Work Breakdown & Ordered DAG

### Step 1: Task43601 — Bind imports and define loud evaluator failures
- **Fixture**: `tests/acceptance/d81/Task43601.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43601`
- **Owned Files**: `asl/tools/engine_js.h`, `asl/tools/asl.c`, `tests/fixtures/unknown_symbol.asl`, `tests/fixtures/cross_module_import.asl`, `asl/grammar/language-semantics.asn`
- **Rationale**: Import resolution and explicit failures are prerequisites for trustworthy tests and the bootstrap.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43601` (guaranteed falsifiable failure on pre-change code).
  2. Apply minimal atomic modifications to declared owned files (`asl/tools/engine_js.h`, `asl/tools/asl.c`, `asl/grammar/language-semantics.asn`).
  3. Execute gate and verify 100% assertions execute with exit code 0.

### Step 2: Task43602 — Require Boolean test results and stable assertion identities
- **Fixture**: `tests/acceptance/d81/Task43602.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43602`
- **Owned Files**: `asl/tools/engine_js.h`, `tests/fixtures/run_tests_false.asl`, `asl/grammar/language-semantics.asn`
- **Rationale**: Test discovery, return values and assertion identities need explicit semantics; broad naming patterns must not silently skip entry points.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43602`.
  2. Apply minimal atomic modifications to declared owned files.
  3. Execute gate and verify 100% assertions execute with exit code 0.

### Step 3: Task43603 — Make RPC capability and result contracts honest
- **Fixture**: `tests/acceptance/d81/Task43603.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43603`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `asl/grammar/protocol-conformance.asn`
- **Rationale**: Machine-readable capabilities and explicit failures reduce false confirmation.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43603`.
  2. Apply minimal atomic modifications to declared owned files.
  3. Execute gate and verify 100% assertions execute with exit code 0.

### Step 4: Task43604 — Document immediate editing and define the staging transition
- **Fixture**: `tests/acceptance/d81/Task43604.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43604`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `AGENTS.md`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Rationale**: Editing must report state it actually holds; the transition must allow a correct no-op discard.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43604`.
  2. Apply minimal atomic modifications to declared owned files.
  3. Execute gate and verify 100% assertions execute with exit code 0.

### Step 5: Task43605 — Verify assertion reachability and preserve runner failures
- **Fixture**: `tests/acceptance/d81/Task43605.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43605`
- **Owned Files**: `asl/tools/asl.c`, `asl/packages/asl-gates/src/polarity.asl`, `scripts/run-gate-tests.sh`, `asl/grammar/verification-contract.asn`
- **Rationale**: Reached sites, repeated executions and source declarations are different quantities; numeric coverage cannot be inferred from text labels.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43605`.
  2. Apply minimal atomic modifications to declared owned files.
  3. Execute gate and verify 100% assertions execute with exit code 0.

### Step 6: Task43606 — Ground claims in executable evidence and reject empty catalogs
- **Fixture**: `tests/acceptance/d81/Task43606.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43606`
- **Owned Files**: `asl/packages/asl-gates/src/site-claims.asl`, `asl/bench/published_claims.asn`, `asl/tools/asl.c`, `asl/grammar/verification-contract.asn`
- **Rationale**: Published claims require provenance and a reproducible measurement, not self-comparison or file existence.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43606`.
  2. Apply minimal atomic modifications to declared owned files.
  3. Execute gate and verify 100% assertions execute with exit code 0.

### Step 7: Task43607 — Declare host boundaries and detect foreign package logic
- **Fixture**: `tests/acceptance/d81/Task43607.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task43607`
- **Owned Files**: `.aslignore`, `asl/tools/asl.c`, `asl/packages/asl-gates/src/shebang_audit.asl`, `asl/grammar/dependency-boundaries.asn`
- **Rationale**: Pure application source and independence from required third-party binaries are distinct boundaries; audit both honestly.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task43607`.
  2. Apply minimal atomic modifications to declared owned files.
  3. Execute gate and verify 100% assertions execute with exit code 0.
