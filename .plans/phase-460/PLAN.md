# Phase 460 Plan: Scheme Alignment and Racket Concepts

## Status
- **Phase**: Phase460SchemeAlignmentAndRacketConcepts
- **Priority**: High Architectural & Language Alignment
- **Status**: in-progress

## Context & Objectives
Align AgentScript core forms with Scheme and Racket conventions where measured token cost is zero, adopt Racket designs for module resolution, syntax locations, and blame-assigning contracts, while strictly excluding Racket from the deployed runtime:
1. Rename core forms to Scheme spellings at measured zero token cost (`define`, `struct`, `enum`, `lambda`, `match`, `begin`, `provide`, `require`, `field`, `string`, `null`).
2. Adopt Racket binding shape `(let ([a 1] [b 2]) body)` and decline Clojure shape, recording the 0.69% measured trade.
3. Adopt Racket module system as the reference design for resolution and cycle detection.
4. Attach source location (source, line, col) to every AST form like syntax objects for precise blame attribution.
5. Introduce contracts with blame on boundaries (precondition blames caller, postcondition blames definition).
6. Record architectural decision: Racket is reference and optional development oracle, never a deployed runtime dependency.

## Work Breakdown & Ordered DAG

### Step 1: Task46001 — Rename Core Forms to Scheme Spellings [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46001.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46001`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define schemeCoreFormsAlignment semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/grammar/grammar.asn`, `asl/tools/engine_js.h`, `asl/packages`, `harness/src`, `intel/src`, `mem/src`, `agent-core/src`.
- Implementation:
  1. Define `schemeCoreFormsAlignment` and `zeroCostAbbreviationRetirement` semantics in `asl/grammar/language-semantics.asn`.
  2. Ground 16,041 uses across 11 core single-token forms (`define`, `struct`, `enum`, `lambda`, `match`, `begin`, `provide`, `require`, `field`, `string`, `null`) with zero token delta in Phase 460 task file.
  3. Verify all 3 stages of `SuperviseGate.sh Task46001` (17 assertions executed cleanly).

### Step 2: Task46002 — Adopt Racket Binding Shape [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46002.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46002`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define racketBindingShape semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/tools/engine_js.h`, `asl/packages`, `harness/src`.
- Implementation:
  1. Define `racketBindingShape` and `clojureBindingShapeRejection` semantics in `asl/grammar/language-semantics.asn`.
  2. Ground 5,249 uses and recorded rejection of 0.69% Clojure binding trade to maintain single-reference dialect alignment.
  3. Verify all 3 stages of `SuperviseGate.sh Task46002` (17 assertions executed cleanly).

### Step 3: Task46003 — Racket Module System Design for Resolution [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46003.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46003`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define racketModuleResolution semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/grammar/dependency-boundaries.asn`.
- Implementation:
  1. Define `racketModuleResolution`, `moduleCycleDetection`, and `singleModuleInstantiation` semantics in `asl/grammar/language-semantics.asn`.
  2. Specify `collectionRoots` in `asl/grammar/dependency-boundaries.asn`.
  3. Verify all 3 stages of `SuperviseGate.sh Task46003` (20 assertions executed cleanly).

### Step 4: Task46004 — Source Location Tracking (Syntax Objects) [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46004.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46004`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define sourceLocationPreservation semantic`.
- Owned Files: `asl/tools/engine_js.h`, `asl/tools/asl.c`.
- Implementation:
  1. Define `sourceLocationPreservation` and `diagnosticPositionQuoting` semantics in `asl/grammar/language-semantics.asn`.
  2. Connect diagnostic error reporting to syntax object positions carrying source, line, column, and span.
  3. Ground re-attribution of 52 of 136 failing suites in Phase 460 task file.
  4. Verify all 3 stages of `SuperviseGate.sh Task46004` (19 assertions executed cleanly).

### Step 5: Task46005 — Contracts with Blame [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46005.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46005`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define contractBlameAttribution semantic`.
- Owned Files: `asl/grammar/verification-contract.asn`, `asl/tools/engine_js.h`, `asl/packages/asl-gates/src`.
- Implementation:
  1. Define `contractBlameAttribution` semantics in `asl/grammar/language-semantics.asn` and rules in `asl/grammar/verification-contract.asn`.
  2. Connect structured gate findings to mechanical blame attribution (preconditions blame caller, postconditions blame definition, deferred checks marked unchecked).
  3. Verify all 3 stages of `SuperviseGate.sh Task46005` (20 assertions executed cleanly).

### Step 6: Task46006 — Record Decision: Racket as Reference, Not Deployment Runtime
- Fixture: `tests/acceptance/d81/Task46006.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46006`
- Owned Files: `.asl/mem/decisions`, `asl/grammar/dependency-boundaries.asn`, `asl/grammar/rules.asn`.
- Implementation:
  1. Record architectural decision in `.asl/mem/decisions/` and `intent.asn`.
  2. Update boundary check in `dependency-boundaries.asn` and `rules.asn`.
  3. Verify all 3 stages of `SuperviseGate.sh Task46006`.
