# Phase 445 Plan: Static Confirmation Coverage

## Status
- **Phase**: Phase445StaticConfirmationCoverage
- **Priority**: Static Confirmation Coverage & Rule Verification
- **Status**: completed

## Context & Objectives
Execute Phase 445 under ADR-0081 and monorepo verification contracts:

1. **Task44501**: Grammar parser for rules.asn and automated rendering consistency
   - *Rationale*: Rendered rule surfaces must be deterministically generated and verified from the tracked single source of truth `asl/grammar/rules.asn`.
2. **Task44502**: Static checkers for the eleven unconfirmed rules
   - *Rationale*: Rules without automated checks degrade into prompt suggestions; all rules must carry static or dynamic confirmation checkers.
3. **Task44503**: C3 duplicate capability checker and the camelCase convergence checker
   - *Rationale*: Prevent cross-package duplicate helper proliferation and enforce identifier token compaction.
4. **Task44504**: Concept-to-checker coverage report
   - *Rationale*: Generate comprehensive coverage reporting mapping every normative principle in ADR-0081 to an executable verification command.

## Work Breakdown & Ordered DAG

### Step 1: Task44501 — Grammar parser for rules.asn and automated rendering consistency
- **Fixture**: `tests/acceptance/d81/Task44501.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44501`
- **Owned Files**: `asl/grammar/rules.asn`, `asl/tools/asl.c`, `scripts/install.sh`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44501`.
  2. Implement native C parser in `asl.c` for `rules.asn` with `--render-rules` and `--check-rules` commands.
  3. Execute gate and verify assertions pass.

### Step 2: Task44502 — Static checkers for the eleven unconfirmed rules
- **Fixture**: `tests/acceptance/d81/Task44502.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44502`
- **Owned Files**: `asl/tools/asl.c`, `asl/packages/asl-gates/src`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44502`.
  2. Implement static checkers for foreign dependencies, oneStep receipt validation, and gate integrity.
  3. Execute gate and verify assertions pass.

### Step 3: Task44503 — C3 duplicate capability checker and the camelCase convergence checker
- **Fixture**: `tests/acceptance/d81/Task44503.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44503`
- **Owned Files**: `asl/tools/asl.c`, `asl/packages/asl-gates/src`, `.asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44503`.
  2. Implement AST-level duplicate function detection and identifier naming convention auditor.
  3. Execute gate and verify assertions pass.

### Step 4: Task44504 — Concept-to-checker coverage report
- **Fixture**: `tests/acceptance/d81/Task44504.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44504`
- **Owned Files**: `asl/tools/asl.c`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44504`.
  2. Add `asl audit coverage` subcommand reporting concept-to-checker verification matrices.
  3. Execute gate and verify assertions pass.
