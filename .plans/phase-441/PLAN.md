# Phase 441 Plan: Attention Prosthesis and Session Invariants

## Status
- **Phase**: Phase441AttentionProsthesis
- **Priority**: Attention Prosthesis, Memory Continuity & Session Invariants
- **Status**: completed

## Context & Objectives
Execute Phase 441 under ADR-0081 and monorepo verification contracts:

1. **Task44101**: Bind session progression to trusted runner receipts
2. **Task44102**: Deliver applicable rules without changing the stable prefix
3. **Task44103**: Bound total retrieval and preserve snapshot-consistent continuation
4. **Task44104**: Preserve authorization and evidence across handoff/resume
5. **Task44105**: Protect hidden acceptance across every tool path
6. **Task44106**: Evaluate attention policies with repeated reliable task outcomes
7. **Task44107**: Document the verified portable loop and current fallbacks
8. **Task44108**: Handle uncovered steps with reversible containment and escalation
9. **Task44109**: Generate useful minimal/full tiers with exact measured budgets
10. **Task44110**: Use justified domain profiles over common mechanical roles

## Work Breakdown & Ordered DAG

### Step 1: Task44101 — Bind session progression to trusted runner receipts
- **Fixture**: `tests/acceptance/d81/Task44101.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44101`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `.asl/mem/tasks/InFlight.asn`, `asl/grammar/verification-contract.asn`, `asl/grammar/session-contract.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44101`.
  2. Implement runner receipt validation bound to session, step, and gate in C host.
  3. Execute gate and verify assertions pass.

### Step 2: Task44102 — Deliver applicable rules without changing the stable prefix
- **Fixture**: `tests/acceptance/d81/Task44102.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44102`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44102`.
  2. Enforce byte-stable prompt prefix caching with dynamic step-scoped rule appendages.
  3. Execute gate and verify assertions pass.

### Step 3: Task44103 — Bound total retrieval and preserve snapshot-consistent continuation
- **Fixture**: `tests/acceptance/d81/Task44103.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44103`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `asl/grammar/session-contract.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44103`.
  2. Enforce `:limit` bounds on AST/symbol retrieval with snapshot continuation tokens.
  3. Execute gate and verify assertions pass.

### Step 4: Task44104 — Preserve authorization and evidence across handoff/resume
- **Fixture**: `tests/acceptance/d81/Task44104.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44104`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `.asl/mem/tasks/InFlight.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44104`.
  2. Implement serialized authorization tokens and checkpoint digests across agent handoffs.
  3. Execute gate and verify assertions pass.

### Step 5: Task44105 — Protect hidden acceptance across every tool path
- **Fixture**: `tests/acceptance/d81/Task44105.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44105`
- **Owned Files**: `.claude/agents/scout.md`, `.claude/agents/implementer.md`, `.claude/agents/grader.md`, `asl/tools/asl.c`, `AGENTS.md`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44105`.
  2. Protect grader acceptance suites from author modification at the tool execution layer.
  3. Execute gate and verify assertions pass.

### Step 6: Task44106 — Evaluate attention policies with repeated reliable task outcomes
- **Fixture**: `tests/acceptance/d81/Task44106.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44106`
- **Owned Files**: `asl/bench/attention_prosthesis.asl`, `.asl/mem/receipts.asn`, `asl/bench/attention_fixtures`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44106`.
  2. Run empirical attention prosthesis benchmark across 12 discriminator tasks.
  3. Execute gate and verify assertions pass.

### Step 7: Task44107 — Document the verified portable loop and current fallbacks
- **Fixture**: `tests/acceptance/d81/Task44107.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44107`
- **Owned Files**: `.agents/skills/asl-toolbelt/SKILL.md`, `asl/asl`, `asl/grammar/rules.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44107`.
  2. Update skill manifests to document fallback paths for absent capabilities.
  3. Execute gate and verify assertions pass.

### Step 8: Task44108 — Handle uncovered steps with reversible containment and escalation
- **Fixture**: `tests/acceptance/d81/Task44108.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44108`
- **Owned Files**: `asl/tools/asl.c`, `asl/grammar/rpc.asn`, `asl/grammar/rules.asn`, `tests/fixtures/edge_scenario.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44108`.
  2. Implement protocol `:escalate` response when no plan step covers active conditions.
  3. Execute gate and verify assertions pass.

### Step 9: Task44109 — Generate useful minimal/full tiers with exact measured budgets
- **Fixture**: `tests/acceptance/d81/Task44109.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44109`
- **Owned Files**: `asl/grammar/rules.asn`, `asl/asl`, `asl/tools/asl.c`, `asl/bench/tier_budget.asl`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44109`.
  2. Implement tier rendering (`:essential`, `:hot`, `:affordance`, `:orientation`, `:heuristic`, `:full`).
  3. Execute gate and verify assertions pass.

### Step 10: Task44110 — Use justified domain profiles over common mechanical roles
- **Fixture**: `tests/acceptance/d81/Task44110.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44110`
- **Owned Files**: `.claude/agents`, `.asl/profiles.asn`, `asl/asl`, `asl/grammar/rules.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44110`.
  2. Ground subagent role definitions in verifiable domain capabilities and telemetry.
  3. Execute gate and verify assertions pass.
