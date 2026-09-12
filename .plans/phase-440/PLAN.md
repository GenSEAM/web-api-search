# Phase 440 Plan: Full ASL Self Hosting

## Status
- **Phase**: Phase440FullAslSelfHosting
- **Priority**: Full ASL Self-Hosting & Native Tooling Independence
- **Status**: planned

## Context & Objectives
Execute Phase 440 under ADR-0081 and monorepo verification contracts:

1. **Task44001**: Implement the evaluator in ASL under canonical conformance
   - *Rationale*: Self-hosted semantics must be independently specified before replacing the bootstrap implementation.
2. **Task44002**: Close native and WASM compiler bootstrap generations
   - *Rationale*: Two compiler targets (native and WASM) prevent compiler-specific semantics from masquerading as language truth.
3. **Task44003**: Route all tooling through the self-hosted native artifact
   - *Rationale*: Native binary independence from external script runners and intermediate C host dependencies.
4. **Task44004**: Verify self-hosted gates using independent negative controls
   - *Rationale*: A compiler that accepts all inputs is indistinguishable from one that verifies all inputs; negative controls are mandatory.
5. **Task44005**: Publish only settled measured self-hosting and language claims
   - *Rationale*: Claims of self-hosting and performance must cite reproducible artifacts and benchmark receipts.

## Work Breakdown & Ordered DAG

### Step 1: Task44001 — Implement the evaluator in ASL under canonical conformance
- **Fixture**: `tests/acceptance/d81/Task44001.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44001`
- **Owned Files**: `asl/packages/asl-eval`, `asl/grammar/language-semantics.asn`
- **Rationale**: Self-hosted semantics must be independently specified.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44001`.
  2. Implement pure ASL AST evaluator matching canonical semantics.
  3. Execute gate and verify assertions pass.

### Step 2: Task44002 — Close native and WASM compiler bootstrap generations
- **Fixture**: `tests/acceptance/d81/Task44002.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44002`
- **Owned Files**: `asl/packages/asl-compiler`, `asl/packages/asl-codegen`, `asl/bin/asl-self.wasm`, `asl/grammar/bootstrap-contract.asn`, `asl/bin/asl-self`
- **Rationale**: Dual target compilation ensures language portable semantics.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44002`.
  2. Implement WASM and native C emission pipelines in `asl-compiler` and `asl-codegen`.
  3. Execute gate and verify assertions pass.

### Step 3: Task44003 — Route all tooling through the self-hosted native artifact
- **Fixture**: `tests/acceptance/d81/Task44003.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44003`
- **Owned Files**: `asl/tools/asl.c`, `asl/packages/asl-cli`, `asl/packages/asl-gates`, `asl/packages/asl-checker`, `asl/packages/asl-lint`, `intel`
- **Rationale**: Full sovereign independence from foreign script runtimes.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44003`.
  2. Connect CLI subcommands directly to self-hosted compiler and evaluator binaries.
  3. Execute gate and verify assertions pass.

### Step 4: Task44004 — Verify self-hosted gates using independent negative controls
- **Fixture**: `tests/acceptance/d81/Task44004.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44004`
- **Owned Files**: `.aslignore`, `asl/packages/asl-gates`, `asl/grammar/verification-contract.asn`
- **Rationale*: Ensure gates reject faulty compiler outputs with genuine error receipts.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44004`.
  2. Implement negative control fixtures and verify proper failure reporting.
  3. Execute gate and verify assertions pass.

### Step 5: Task44005 — Publish only settled measured self-hosting and language claims
- **Fixture**: `tests/acceptance/d81/Task44005.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44005`
- **Owned Files**: `MANIFESTO.md`, `TOKEN_DENSITY_ANALYSIS.md`, `asl/grammar/rules.asn`, `scripts/install.sh`, `.asl/mem/decisions/Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn`
- **Rationale**: Synchronize documentation with measured realities.
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44005`.
  2. Update all public claims to match empirical measurements.
  3. Execute gate and verify assertions pass.
