# Phase 462 Plan: LLM-First Lexicon

## Status
- **Phase**: Phase462LlmFirstLexicon
- **Priority**: Critical Token Economy & Lexical Density
- **Status**: in-progress

## Context & Objectives
Govern the entire lexicon by measured token cost under cl100k, removing human aesthetic bias and serving human readability through decoders rather than source alterations:
1. Selection rule: Measured cost decides naming; length and pattern uniformity do not.
2. Symbol admission: No symbol enters the language unmeasured; gate enforcement verifies every symbol.
3. Excess closure: Systematically close the measured excess in the existing lexicon across packages.
4. Human decoders: The human reads a decoder or formatter, never forcing bloated source representations.
5. Lossless substrate: Code and ASN convert without information loss across representations.
6. Portable semantic structures: Structures carry explicit semantic meaning across agents and models.

## Work Breakdown & Ordered DAG

### Step 1: Task46201 — The Selection Rule: Measured Cost Decides, Length and Pattern Do Not [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46201.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46201`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define measuredTokenCostSelectionRule semantic`.
- Owned Files: `asl/grammar/rules.asn`, `TOKEN_CONVENTIONS.md`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `measuredTokenCostSelectionRule` semantics in `asl/grammar/language-semantics.asn`.
  2. Ground selection rule in `TOKEN_CONVENTIONS.md`: measured token cost decides, length and family uniformity excluded.
  3. Verify all 3 stages of `SuperviseGate.sh Task46201` (19 assertions executed cleanly).

### Step 2: Task46202 — No Symbol Enters the Language Unmeasured [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46202.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46202`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define symbolAdmissionMeasuredCostRule semantic`.
- Owned Files: `asl/grammar/grammar.asn`, `asl/tools/asl.c`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `symbolAdmissionMeasuredCostRule` semantics in `asl/grammar/language-semantics.asn`.
  2. Require measured token count and considered alternatives on symbol admission in `grammar.asn`.
  3. Verify all 3 stages of `SuperviseGate.sh Task46202` (18 assertions executed cleanly).

### Step 3: Task46203 — Close the Measured Excess in the Existing Lexicon [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46203.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46203`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define closedSetSingleTokenKeywordRule semantic`.
- Owned Files: `asl/grammar/grammar.asn`, `asl/packages`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `closedSetSingleTokenKeywordRule` semantics in `asl/grammar/language-semantics.asn`.
  2. Ground closed set single-token requirement and open set CamelCase minimum spelling in Phase 462 task ledger.
  3. Verify all 3 stages of `SuperviseGate.sh Task46203` (18 assertions executed cleanly).

### Step 4: Task46204 — The Human Reads a Decoder, Never the Source [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46204.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46204`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define humanDecoderSeparation semantic`.
- Owned Files: `asl/tools/asl.c`, `asl/grammar/protocol-conformance.asn`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `humanDecoderSeparation` semantics in `asl/grammar/language-semantics.asn`.
  2. Specify `decoderTool` contract in `protocol-conformance.asn` ensuring human-readable decoding without source re-entry.
  3. Verify all 3 stages of `SuperviseGate.sh Task46204` (19 assertions executed cleanly).

### Step 5: Task46205 — One Substrate: Code and ASN Convert Without Loss [COMPLETED & CERTIFIED]
- Fixture: `tests/acceptance/d81/Task46205.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46205`
- Baseline: Failed with `[ASL_ASSERTION_FAILURE]: language-semantics.asn must define losslessAsnCodeConversion semantic`.
- Owned Files: `asl/grammar/language-semantics.asn`, `asl/packages/asl-codec/grammar.asn`.
- Implementation:
  1. Define `losslessAsnCodeConversion` semantics in `asl/grammar/language-semantics.asn`.
  2. Enforce total, bidirectional, lossless conversion between S-expression forms and ASN records with preserved positions and escaping in `asl-codec/grammar.asn`.
  3. Verify all 3 stages of `SuperviseGate.sh Task46205` (18 assertions executed cleanly).

### Step 6: Task46206 — A Structure Carries Its Own Meaning Across Agents and Models
- Fixture: `tests/acceptance/d81/Task46206.asl`
- Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task46206`
- Owned Files: `asl/grammar/rpc.asn`, `asl/grammar/protocol-conformance.asn`, `asl/grammar/language-semantics.asn`.
- Implementation:
  1. Define `portableSemanticStructure` semantic in `asl/grammar/language-semantics.asn`.
  2. Ground typed self-describing ASN receipts and message structures across models.
  3. Verify all 3 stages of `SuperviseGate.sh Task46206`.
