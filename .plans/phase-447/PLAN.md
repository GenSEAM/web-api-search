# Phase 447 Plan: Canonical Lexicon Cross Client

## Status
- **Phase**: Phase447CanonicalLexiconCrossClient
- **Priority**: Canonical Lexicon Truth & Spoken Vocabulary Parity
- **Status**: completed

## Context & Objectives
Execute Phase 447 under ADR-0081 and monorepo verification contracts:

1. **Task44701**: Canonical lexicon as a single source, rendered to every client
   - *Rationale*: A single tracked lexicon file in `asl/grammar/lexicon.asn` drives all alias tables and transliteration layers across all AI agent clients.
2. **Task44702**: Retire the mishearing from artifact names: hyness becomes harness
   - *Rationale*: Purge legacy audio speech-to-text artifact phonetic drift ("hyness") across source files, configs, and task records.
3. **Task44703**: One table, three consumers: voice transliterator, prompt translator, client channels
   - *Rationale*: Connect voice input processing, prompt preprocessing, and multi-IDE client channels to the unified lexicon table.
4. **Task44704**: Lexicon checker: no orphan alias, no local table, no mishearing in artifacts
   - *Rationale*: Enforce static verification preventing rogue local vocabulary dictionaries and unmapped domain aliases.

## Work Breakdown & Ordered DAG

### Step 1: Task44701 — Canonical lexicon as a single source, rendered to every client
- **Fixture**: `tests/acceptance/d81/Task44701.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44701`
- **Owned Files**: `asl/grammar/lexicon.asn`, `scripts/install.sh`, `AGENTS.md`, `asl/asl`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44701`.
  2. Define canonical lexicon table in `asl/grammar/lexicon.asn` and wire rendering into `install.sh`.
  3. Execute gate and verify assertions pass.

### Step 2: Task44702 — Retire the mishearing from artifact names: hyness becomes harness
- **Fixture**: `tests/acceptance/d81/Task44702.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44702`
- **Owned Files**: `voice/src/hyness_profile.asl`, `voice/tests/audio_bridge_test.asl`, `.asl/hyness.config.asn`, `voice/grammar.asn`, `.asl/mem/tasks/backlog.asn`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44702`.
  2. Rename and refactor all occurrences of `hyness` to `harness` across configurations and test files.
  3. Execute gate and verify assertions pass.

### Step 3: Task44703 — One table, three consumers: voice transliterator, prompt translator, client channels
- **Fixture**: `tests/acceptance/d81/Task44703.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44703`
- **Owned Files**: `voice/src/transliterator.asl`, `harness/src/prompt_translator.asl`, `asl/asl`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44703`.
  2. Connect `voice` transliterator and `harness` prompt translator to parse canonical `lexicon.asn`.
  3. Execute gate and verify assertions pass.

### Step 4: Task44704 — Lexicon checker: no orphan alias, no local table, no mishearing in artifacts
- **Fixture**: `tests/acceptance/d81/Task44704.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44704`
- **Owned Files**: `asl/tools/asl.c`, `asl/packages/asl-gates/src`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44704`.
  2. Implement static lexicon validation gate in `asl audit lexicon`.
  3. Execute gate and verify assertions pass.
