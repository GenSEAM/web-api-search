# Phase 461 Plan: Core and Interchangeable Extensions

## Status
- **Phase**: Phase461CoreAndInterchangeableExtensions
- **Priority**: Critical Architectural Boundary & Extension Layering
- **Status**: in-progress

## Context & Objectives
Enforce strict separation between core language mechanisms and interchangeable extensions under ADR-0081, D34 (Boundary Universalism), and C3:
1. Ensure the core engine and host know zero extension names by hardcoded strings, resolving entirely via declared module graphs.
2. Provide syntax extension mechanisms so domain abstractions reside in libraries rather than engine edits.
3. Establish a single engine interface where engines are interchangeable without the language naming specific runtimes.
4. Require extensions to declare needed host capabilities, enforced by the core at load time.
5. Admit data and view adapters as extensions strictly governed by the Two-Strikes Rule.
6. Enforce strictly unidirectional dependency flow: core never depends on extensions.

## Work Breakdown & Ordered DAG

### Step 1: Task46101 — The Core Knows No Extension by Name [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46101.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46101`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define zeroExtensionKnowledgeInCore semantic`.
- Owned Files: `asl/tools/engine_js.h`, `asl/tools/asl.c`, `asl/grammar/dependency-boundaries.asn`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `zeroExtensionKnowledgeInCore` semantics in `asl/grammar/language-semantics.asn`.
  2. Specify `coreIsolation` and `collectionRoots` in `asl/grammar/dependency-boundaries.asn` and `asl/tools/engine.js`.
  3. Audit and verify zero hardcoded extension paths in core engine sources (eliminated measured 32 paths).
  4. Verify all 3 stages of `SuperviseGate.sh Task46101` (18 assertions executed cleanly).

### Step 2: Task46102 — Syntax Extension: Domain as Library [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46102.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46102`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define syntaxExtensionHygienic semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/tools/engine_js.h`.
- Implementation:
  1. Define `syntaxExtensionHygienic` and `domainAsLibrary` semantics in `asl/grammar/language-semantics.asn`.
  2. Verify macro hygiene and position preservation without domain contamination of the evaluator.
  3. Verify all 3 stages of `SuperviseGate.sh Task46102` (18 assertions executed cleanly).

### Step 3: Task46103 — One Engine Interface with Interchangeable Engines
- Fixture: `tests/acceptance/d81/Task46103.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46103`
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/grammar/dependency-boundaries.asn`.
- Implementation:
  1. Define `interchangeableEngineInterface` semantics in `asl/grammar/language-semantics.asn`.
  2. Specify unified engine host abstraction free of concrete engine name bindings.
  3. Verify all 3 stages of `SuperviseGate.sh Task46103`.

### Step 4: Task46104 — Extensions Declare Required Host Capabilities
- Fixture: `tests/acceptance/d81/Task46104.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46104`
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/grammar/capabilities.asn`.
- Implementation:
  1. Define `extensionDeclaredCapabilities` semantics in `asl/grammar/language-semantics.asn`.
  2. Enforce load-time capability verification between declared requirements and host capabilities.
  3. Verify all 3 stages of `SuperviseGate.sh Task46104`.

### Step 5: Task46105 — Adapters as Extensions on Two-Strikes Rule
- Fixture: `tests/acceptance/d81/Task46105.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46105`
- Owned Files: `asl/grammar/language-semantics.asn`, `.asl/mem/decisions`.
- Implementation:
  1. Define `twoStrikesAdapterAdmission` semantics in `asl/grammar/language-semantics.asn`.
  2. Ensure data/view adapters remain isolated packages and generic interfaces require two concrete implementations.
  3. Verify all 3 stages of `SuperviseGate.sh Task46105`.

### Step 6: Task46106 — Strict Unidirectional Dependency Direction
- Fixture: `tests/acceptance/d81/Task46106.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46106`
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/grammar/dependency-boundaries.asn`.
- Implementation:
  1. Define `unidirectionalDependencyDirection` semantics in `asl/grammar/language-semantics.asn`.
  2. Enforce strict layering check proving core has zero incoming dependencies from extensions.
  3. Verify all 3 stages of `SuperviseGate.sh Task46106`.
