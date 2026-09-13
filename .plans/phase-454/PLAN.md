# Phase 454 Plan: Engine Binding Ground Truth

## Status
- **Phase**: Phase454EngineBindingGroundTruth
- **Priority**: Module Resolution & Dynamic Engine Binding Ground Truth
- **Status**: completed

## Context & Objectives
Execute Phase 454 under ADR-0081 and monorepo verification contracts:

1. **Task45401**: Module resolution reads the declared module graph instead of guessing paths
   - *Rationale*: Module resolution must strictly respect declared manifests in `manifest.asn` rather than performing heuristic directory scans.
2. **Task45402**: An unresolved import is fatal and names the import, not a later call site
   - *Rationale*: Fail-fast semantics on missing symbols to prevent silent runtime exits or late undefined call site crashes.
3. **Task45403**: The 40 missing builtins, with case and match as real control forms
   - *Rationale*: Implement essential control flow and data manipulation primitives directly in engine runtime.
4. **Task45404**: refute as a first class falsification primitive
   - *Rationale*: Provide first-class negation checking to ensure tests verify that faulty states actively fail.
5. **Task45405**: The 22 files that use an alias they never declare
   - *Rationale*: Purge undeclared namespace aliases across agent packages and codec tests.
6. **Task45406**: Re-measure the corpus and make executed assertions the tracked number
   - *Rationale*: Count executed assertions rather than file counts or return codes as the primary ground truth metric.

## Work Breakdown & Ordered DAG

### Step 1: Task45401 — Module resolution reads the declared module graph instead of guessing paths
- **Fixture**: `tests/acceptance/d81/Task45401.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45401`
- **Owned Files**: `asl/tools/engine_js.h`, `asl/tools/gen_engine_header.sh`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task45401`.
  2. Refactor module resolver in `engine_js.h` to use package manifest graph.
  3. Execute gate and verify assertions pass.

### Step 2: Task45402 — An unresolved import is fatal and names the import, not a later call site
- **Fixture**: `tests/acceptance/d81/Task45402.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45402`
- **Owned Files**: `asl/tools/engine_js.h`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task45402`.
  2. Raise immediate fatal error with symbol identifier when an import cannot be resolved.
  3. Execute gate and verify assertions pass.

### Step 3: Task45403 — The 40 missing builtins, with case and match as real control forms
- **Fixture**: `tests/acceptance/d81/Task45403.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45403`
- **Owned Files**: `asl/tools/engine_js.h`, `asl/grammar/language-semantics.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task45403`.
  2. Implement missing core primitives and control forms in the JS evaluator header.
  3. Execute gate and verify assertions pass.

### Step 4: Task45404 — refute as a first class falsification primitive
- **Fixture**: `tests/acceptance/d81/Task45404.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45404`
- **Owned Files**: `asl/tools/engine_js.h`, `docs/TEST_CASE_CATALOG.md`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task45404`.
  2. Implement `refute` special form in engine that asserts the expression evaluates to falsy or throws.
  3. Execute gate and verify assertions pass.

### Step 5: Task45405 — The 22 files that use an alias they never declare
- **Fixture**: `tests/acceptance/d81/Task45405.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45405`
- **Owned Files**: `agent-bus/src`, `agent/src`, `agent-core/src`, `asl/packages/asl-codec/tests`, `intel/src`, `harness/src`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task45405`.
  2. Add missing alias declarations to all 22 affected files.
  3. Execute gate and verify assertions pass.

### Step 6: Task45406 — Re-measure the corpus and make executed assertions the tracked number
- **Fixture**: `tests/acceptance/d81/Task45406.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45406`
- **Owned Files**: `.asl/mem/telemetry`, `scripts/run-gate-tests.sh`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task45406`.
  2. Update test runner scripts and telemetry storage to track executed assertion counts.
  3. Execute gate and verify assertions pass.
