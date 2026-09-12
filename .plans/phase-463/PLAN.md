# Phase 463 Plan: ASL-First Beyond Racket

## Status
- **Phase**: Phase463AslFirstBeyondRacket
- **Priority**: Critical Structural Optimization & Emission Fidelity
- **Status**: active

## Context & Objectives
Optimize AgentScript along axes Racket never optimized: emission reliability, nesting depth, binding distance, and an empirical emission error rate:
1. Nesting depth tracking: Depth is a bounded, tracked quantity reported per file and form with a declared ceiling.
2. Flattening forms: Admitted only on a measured double win (lowers depth and lowers token count).
3. Binding-to-use distance: Enforce bounded locality between bindings and uses over the resolved module graph.
4. Measured emission error rate: Ground language changes in model generation fidelity against fixed task sets.
5. Refuted rewrites ledger: Permanently record refuted structural compaction ideas to prevent redundant re-proposals.

## Work Breakdown & Ordered DAG

### Step 1: Task46301 — Nesting Depth Is a Bounded, Tracked Quantity [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46301.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46301`
- Owned Files: `asl/tools/asl.c`, `.asl/mem/telemetry`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `nestingDepthCeilingRule` semantic in `asl/grammar/language-semantics.asn`.
  2. Implement delimiter depth tracking and ceiling reporting in `asl/tools/asl.c` (excluding string literals).
  3. Verify all 3 stages of `SuperviseGate.sh Task46301` (20 assertions executed cleanly).

### Step 2: Task46302 — Flattening Forms, Adopted Only on a Measured Double Win [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46302.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46302`
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/tools/engine_js.h`.
- Implementation:
  1. Define `flatteningFormDoubleWinRule` semantic in `asl/grammar/language-semantics.asn`.
  2. Require flattening forms to be admitted strictly on a measured double win (depth and token count).
  3. Verify all 3 stages of `SuperviseGate.sh Task46302` (20 assertions executed cleanly).

### Step 3: Task46303 — A Binding Is Never Far From Its Use [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46303.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46303`
- Owned Files: `asl/tools/asl.c`, `asl/packages`, `harness/src`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `bindingToUseDistanceRule` semantic in `asl/grammar/language-semantics.asn`.
  2. Measure and bound binding-to-use distances across packages, requiring self-describing bindings.
  3. Verify all 3 stages of `SuperviseGate.sh Task46303` (20 assertions executed cleanly).

### Step 4: Task46304 — A Measured Emission Error Rate, Which No Language Has [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46304.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46304`
- Owned Files: `asl/bench`, `.asl/mem/telemetry`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `measuredEmissionErrorRateRule` semantic in `asl/grammar/language-semantics.asn`.
  2. Establish fixed benchmark generation task set and measure parsing/binding/assertion failure rates.
  3. Verify all 3 stages of `SuperviseGate.sh Task46304` (20 assertions executed cleanly).


### Step 5: Task46305 — Record the Refuted Rewrites So They Do Not Return
- Fixture: `tests/acceptance/d81/Task46305.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46305`
- Owned Files: `.asl/mem/principles.asn`, `TOKEN_CONVENTIONS.md`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `refutedStructuralRewritesRule` semantic in `asl/grammar/language-semantics.asn`.
  2. Document 3 measured refutations (devowelling, delimiter deletion, indentation-significant rendering) in `TOKEN_CONVENTIONS.md` and `.asl/mem/principles.asn`.
  3. Verify all 3 stages of `SuperviseGate.sh Task46305`.
