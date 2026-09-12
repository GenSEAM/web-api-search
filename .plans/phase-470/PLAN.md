# Phase 470 Plan: Restore Gate Scope and Reach Execution

## Status
- **Phase**: Phase470RestoreGateScopeAndReachExecution
- **Priority**: Gate 5 Monorepo Corpus Scope & Built Binary Parity
- **Status**: planned

## Context & Objectives
Execute Phase 470 under ADR-0081 and monorepo verification contracts:

1. **Task47001**: Gate 5 audits the corpus, not a directory
   - *Rationale*: Gate 5 must traverse the full monorepo package tree (313+ test suites) rather than restricting its audit to a subset directory.
2. **Task47002**: Close the seven remaining module names
   - *Rationale*: Harmonize remaining non-standard module names across agent, mem, intel, and peripheral packages.
3. **Task47003**: The installed binary is the built binary
   - *Rationale*: Guarantee parity between built C artifacts and active `$PATH` binaries (`bin/asl`, `asl/bin/asl`, `asl/asl`).
4. **Task47004**: Fixtures for the tasks that are ready, so work can be claimed
   - *Rationale*: Ensure every ready task carries an executable acceptance fixture in `tests/acceptance/d81/`.
5. **Task47005**: A gate cannot narrow its own scope without saying so
   - *Rationale*: Forbid gates from silently skipping directories or filtering suites without explicit logging.
6. **Task47006**: launch moves into the binary and the script is retired in the same change
   - *Rationale*: Move launcher orchestration directly into `bin/asl` and retire shell scripts.
7. **Task47007**: The rule payload is read from its source, not rendered into a launcher
   - *Rationale*: Rules are projected dynamically from `asl/grammar/rules.asn` rather than baked into static launchers.

## Work Breakdown & Ordered DAG

### Step 1: Task47001 — Gate 5 audits the corpus, not a directory
- **Fixture**: `tests/acceptance/d81/Task47001.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47001`
- **Owned Files**: `asl/tools/asl.c`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47001`.
  2. Expand Gate 5 file discovery in `asl.c` to include all monorepo packages.
  3. Execute gate and verify assertions pass.

### Step 2: Task47002 — Close the seven remaining module names
- **Fixture**: `tests/acceptance/d81/Task47002.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47002`
- **Owned Files**: `agent/src`, `mem/src`, `intel/src`, `asl/packages`, `asl-arduino`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47002`.
  2. Update module declarations to match canonical package namespaces.
  3. Execute gate and verify assertions pass.

### Step 3: Task47003 — The installed binary is the built binary
- **Fixture**: `tests/acceptance/d81/Task47003.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47003`
- **Owned Files**: `asl/tools/asl.c`, `scripts/build_and_install.sh`, `scripts/install.sh`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47003`.
  2. Update build and install scripts to compile directly to the canonical target and verify checksums.
  3. Execute gate and verify assertions pass.

### Step 4: Task47004 — Fixtures for the tasks that are ready, so work can be claimed
- **Fixture**: `tests/acceptance/d81/Task47004.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47004`
- **Owned Files**: `tests/acceptance/d81`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47004`.
  2. Provide complete baseline fixtures for all unclaimed tasks in backlog.
  3. Execute gate and verify assertions pass.

### Step 5: Task47005 — A gate cannot narrow its own scope without saying so
- **Fixture**: `tests/acceptance/d81/Task47005.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47005`
- **Owned Files**: `asl/tools/asl.c`, `tests/acceptance/d81`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47005`.
  2. Add scope integrity checks that fail if any test suite is skipped or excluded.
  3. Execute gate and verify assertions pass.

### Step 6: Task47006 — launch moves into the binary and the script is retired in the same change
- **Fixture**: `tests/acceptance/d81/Task47006.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47006`
- **Owned Files**: `asl/tools/asl.c`, `asl/asl`, `scripts/build_and_install.sh`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47006`.
  2. Embed launcher command handling in native C binary and remove redundant shell wrapper.
  3. Execute gate and verify assertions pass.

### Step 7: Task47007 — The rule payload is read from its source, not rendered into a launcher
- **Fixture**: `tests/acceptance/d81/Task47007.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47007`
- **Owned Files**: `asl/tools/asl.c`, `scripts/install.sh`, `asl/grammar/rules.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task47007`.
  2. Refactor client launch to read rules dynamically from `rules.asn`.
  3. Execute gate and verify assertions pass.
