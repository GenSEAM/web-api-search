# Phase 459 Plan: Language Compaction and Predictability

## Status
- **Phase**: Phase459LanguageCompactionAndPredictability
- **Priority**: Critical Language Predictability & Token Grounding
- **Status**: in-progress

## Context & Objectives
Address corpus fragmentation and establish one name per concept before 40 new builtins are introduced:
1. One name per concept decided in grammar: predicates end in `?` (no `is-` prefix), constructors use `make-`, conversions use `source-to-target`.
2. Rename the 14 measured expensive builtins (`string-contains?`, `string-starts-with?`, etc.) with zero aliases left behind.
3. Multi-word identifiers converted mechanically to CamelCase with exact before/after cl100k measurement.
4. Retire opaque 1-2 character aliases, enforcing legible prefixes (>=3 chars) at deliberate 0.74% token cost.
5. Track symbol surface alongside token count as the quantity governing LLM accuracy.
6. Correct D51 claim to its measured scope (per-identifier 44-50%, corpus-wide 3.06%).

## Work Breakdown & Ordered DAG

### Step 1: Task45901 — One Name per Concept Decided in Grammar [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task45901.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45901`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define predicateNaming semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/grammar/grammar.asn`, `TOKEN_CONVENTIONS.md`.
- Implementation:
  1. Add canonical naming semantics to `asl/grammar/language-semantics.asn`:
     - `predicateNaming`: must end in `?` and reject `is-` prefix (`ERR_RETIRED_PREDICATE_FORM`).
     - `constructorNaming`: must use `make-` prefix (`ERR_RETIRED_CONSTRUCTOR_FORM`).
     - `conversionNaming`: must use `source-to-target` format (`ERR_RETIRED_CONVERSION_FORM`).
  2. Document the "One Name per Concept" standard in `TOKEN_CONVENTIONS.md` highlighting `empty?` and retired forms.
  3. Ensure `asl/grammar/grammar.asn` conforms to the canonical forms.
  4. Verify all 3 stages of `SuperviseGate.sh Task45901` (21 assertions executed cleanly).
  5. Commits: `e884065` (asl submodule), `7e63403` (root repository).

### Step 2: Task45902 — Rename the 14 Measured Expensive Builtins [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task45902.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45902`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define expensiveBuiltinsRenamed semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/tools/engine_js.h`.
- Implementation:
  1. Add `expensiveBuiltinsRenamed` and `zeroCompatibilityAliases` semantics to `asl/grammar/language-semantics.asn`.
  2. Ground 0.97% token compaction and 14,712 tokens frequency-times-cost in Phase 459 task file.
  3. Verify all 3 stages of `SuperviseGate.sh Task45902` (16 assertions executed cleanly).

### Step 3: Task45903 — CamelCase for Multi-Word Identifiers [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task45903.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45903`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define assertionParityAcrossTransformations semantic`.
- Owned Files: `asl/packages`, `harness/src`, `intel/src`, `mem/src`, `agent-core/src`, `vdom/src`.
- Implementation:
  1. Add `assertionParityAcrossTransformations` and `stringLiteralPreservation` semantics to `asl/grammar/language-semantics.asn`.
  2. Ground 3.06% corpus-wide saving and 46,259 tokens saved in Phase 459 task file.
  3. Verify all 3 stages of `SuperviseGate.sh Task45903` (16 assertions executed cleanly).

### Step 4: Task45904 — Retire Opaque Aliases [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task45904.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45904`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define legibleAliasLength semantic`.
- Owned Files: `asl/packages`, `harness/src`, `agent-bus/src`, `intel/src`, `mem/src`, `voice/src`.
- Implementation:
  1. Add `legibleAliasLength`, `globalPrefixUniqueness`, and `selfContainedSliceResolution` semantics to `asl/grammar/language-semantics.asn`.
  2. Ground 0.74% deliberate token cost and 11,132 extra tokens in Phase 459 task file.
  3. Verify all 3 stages of `SuperviseGate.sh Task45904` (20 assertions executed cleanly).

### Step 5: Task45905 — Symbol Surface as Tracked Quantity [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task45905.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45905`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define symbolSurfaceTracking semantic`.
- Owned Files: `asl/grammar/rules.asn`, `.asl/mem/telemetry`, `TOKEN_CONVENTIONS.md`.
- Implementation:
  1. Add `symbolSurfaceTracking`, `symbolSurfaceRatchet`, and `dualQuantityInventory` semantics to `asl/grammar/language-semantics.asn`.
  2. Ground 17,112 distinct head symbols, 1,512,691 corpus tokens, and dual-run telemetry in `.asl/mem/telemetry/SymbolSurface20260912.asn`.
  3. Document Section 8 on symbol surface tracking, ratchet policy, and trade rule in `TOKEN_CONVENTIONS.md`.
  4. Verify all 3 stages of `SuperviseGate.sh Task45905` (25 assertions executed cleanly).

### Step 6: Task45906 — Correct D51 Claim to Measured Scope [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task45906.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45906`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define groundedNumericClaims semantic`.
- Owned Files: `TOKEN_CONVENTIONS.md`, `asl/grammar/rules.asn`, `AGENTS.md`.
- Implementation:
  1. Add `groundedNumericClaims` and `dualScopeCompactionReport` semantics to `asl/grammar/language-semantics.asn`.
  2. Correct D51 claim across `TOKEN_CONVENTIONS.md`, `asl/grammar/rules.asn`, and `AGENTS.md` to state 44% to 50% per long identifier and 3.06% corpus-wide across 888 files on 2026-09-12 under cl100k.
  3. Render updated rules to all surfaces via `./scripts/install.sh --render-rules` and verify via `./scripts/install.sh --check-rules`.
  4. Verify all 3 stages of `SuperviseGate.sh Task45906` (27 assertions executed cleanly).
  5. Settle Phase 459 in `.asl/mem/roadmap.asn` as `done`.
