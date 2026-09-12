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

### Step 1: Task45901 — One Name per Concept Decided in Grammar
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
  4. Verify all 3 stages of `SuperviseGate.sh Task45901`.

### Step 2: Task45902 — Rename the 14 Measured Expensive Builtins
- Fixture: `tests/acceptance/d81/Task45902.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45902`
- Implementation: Rename 14 high-frequency multi-token primitives to unambiguous short forms without backward-compat aliases.

### Step 3: Task45903 — CamelCase for Multi-Word Identifiers
- Fixture: `tests/acceptance/d81/Task45903.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45903`
- Implementation: Mechanical transformation and assertion parity verification across monorepo packages.

### Step 4: Task45904 — Retire Opaque Aliases
- Fixture: `tests/acceptance/d81/Task45904.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45904`
- Implementation: Enforce 3+ character legible prefixes, single global meaning per prefix.

### Step 5: Task45905 — Symbol Surface as Tracked Quantity
- Fixture: `tests/acceptance/d81/Task45905.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45905`
- Implementation: Inventory distinct symbol surface and add ratchet checks.

### Step 6: Task45906 — Correct D51 Claim to Measured Scope
- Fixture: `tests/acceptance/d81/Task45906.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task45906`
- Implementation: Update `TOKEN_CONVENTIONS.md`, `asl/grammar/rules.asn`, and `AGENTS.md` with exact scopes and empirical methods.
